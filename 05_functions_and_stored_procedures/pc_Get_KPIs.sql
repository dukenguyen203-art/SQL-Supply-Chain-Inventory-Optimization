USE InventoryAnalytics;
GO

/*
Procedure: usp_Get_KPIs_Period
    Purpose:
        Compute executive-level KPIs for any user-defined date period.
        If @StartDate or @EndDate is NULL → use full dataset.

   KPIs Returned:
        1. Total_Sales_Revenue
        2. Gross_Margin_Pct
        3. Forecast_Accuracy_WAPE_Pct
        4. Forecast_Stability_StdDev_APE_Pct
        5. Avg_Inventory_Value
        6. Slow_Moving_Inventory_Value_Pct
        7. Supplier_Concentration_Top3_Pct
        8. Avg_Supplier_LeadTime_CV
*/

CREATE OR ALTER PROCEDURE sc_inventory.usp_Get_KPIs_Period
(
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- determine effective date range
    IF @StartDate IS NULL
        SELECT @StartDate = (SELECT MIN(DateValue) FROM sc_inventory.vw_DailyInventory);
    
    IF @EndDate IS NULL
        SELECT @EndDate = (SELECT MAX(DateValue) FROM sc_inventory.vw_DailyInventory);

    -- Filtered dataset for the specified date range
    ;WITH FactFiltered AS (
        SELECT *
        FROM sc_inventory.vw_DailyInventory
        WHERE DateValue BETWEEN @StartDate AND @EndDate
    )

    -- KPI 1 & 2: Total Sales Revenue and Gross Margin %
    ,KPI_Sales AS (
        SELECT
            SUM(Revenue) AS Total_Sales_Revenue,
            CASE 
                WHEN SUM(Revenue) = 0 THEN NULL
                ELSE (SUM(Revenue) - SUM(Cogs)) / SUM(Revenue) * 100
            END AS Gross_Margin_Pct
        FROM FactFiltered
    )

    -- KPI 3 & 4: Forecast Accuracy (WAPE %) and Forecast Stability (StdDev APE %)
    ,ForecastAgg AS (
        SELECT
            SKU_ID,
            SUM(Units_Sold) AS ActualUnits,
            SUM(Demand_Forecast) AS ForecastUnits
        FROM FactFiltered
        GROUP BY SKU_ID
    ),
    ForecastAPE AS (
        SELECT
            SKU_ID,
            ActualUnits,
            ForecastUnits,
            CASE 
                WHEN ActualUnits = 0 THEN NULL
                ELSE ABS(ActualUnits - ForecastUnits) / ActualUnits * 100
            END AS APE_Pct
        FROM ForecastAgg
    ),
    KPI_Forecast AS (
        SELECT
            CASE 
                WHEN SUM(ActualUnits) = 0 THEN NULL
                ELSE SUM(ABS(ActualUnits - ForecastUnits)) / SUM(ActualUnits) * 100
            END AS Forecast_Accuracy_WAPE_Pct,
            STDEV(APE_Pct) AS Forecast_Stability_StdDev_APE_Pct
        FROM ForecastAPE
    )
    
    -- KPI 5 & 6: Avg Inventory Value and Slow Moving Inventory Value %
    ,MonthlyInventory AS (
        SELECT *
        FROM sc_inventory.vw_InventoryHealth_Monthly
        WHERE CAST(CONCAT(Year, RIGHT('0' + CAST(Month AS VARCHAR(2)), 2), '01') AS DATE) 
              BETWEEN @StartDate AND @EndDate
    ),
    InvJoin AS (
        SELECT
            [Year],
            [Month],
            SKU_ID,
            Warehouse_ID,
            AvgInventoryLevel,
            DOH,
            AvgUnitCost * AvgInventoryLevel AS InventoryValue
        FROM MonthlyInventory
    ),
    KPI_Inventory AS (
        SELECT
            AVG(InventoryValue) AS Avg_Inventory_Value,
            SUM (CASE WHEN DOH > 21 THEN InventoryValue ELSE 0 END) / SUM(InventoryValue) * 100 -- threshold: DOH > 21 days
            AS Slow_Moving_Inventory_Value_Pct
        FROM InvJoin
    )

    -- KPI 7 & 8: Supplier Concentration (Top 3 %) and Avg Supplier LeadTime CV
    ,SupplierSpend AS (
        SELECT
            Supplier_ID,
            SUM(Cogs) AS Spend
        FROM FactFiltered
        GROUP BY Supplier_ID
    ),
    KPI_Suppliers AS (
        SELECT
            Supplier_Concentration_Top3_Pct = 
                100 *(
                    SELECT SUM(Spend) 
                    FROM (
                        SELECT TOP 3 Spend
                        FROM SupplierSpend
                        ORDER BY Spend DESC
                    ) t
                ) / (SELECT SUM(Spend) FROM SupplierSpend),
            
            Avg_Supplier_LeadTime_CV =
                (SELECT AVG(LeadTime_CV) FROM sc_inventory.vw_SupplierPerformance 
                WHERE CAST(CONCAT(Year, RIGHT('0' + CAST(Month AS VARCHAR(2)), 2), '01') AS DATE) 
                    BETWEEN @StartDate AND @EndDate)
    )

    -- Final SELECT to return all KPIs
    SELECT
        ROUND(s.Total_Sales_Revenue, 2) AS Total_Sales_Revenue,
        ROUND(s.Gross_Margin_Pct, 2) AS Gross_Margin_Pct,
        ROUND(f.Forecast_Accuracy_WAPE_Pct, 2) AS Forecast_Accuracy_WAPE_Pct,
        ROUND(f.Forecast_Stability_StdDev_APE_Pct, 2) AS Forecast_Stability_StdDev_APE_Pct,
        ROUND(i.Avg_Inventory_Value, 2) AS Avg_Inventory_Value,
        ROUND(i.Slow_Moving_Inventory_Value_Pct, 2) AS Slow_Moving_Inventory_Value_Pct,
        ROUND(sp.Supplier_Concentration_Top3_Pct, 2) AS Supplier_Concentration_Top3_Pct,
        ROUND(sp.Avg_Supplier_LeadTime_CV, 2) AS Avg_Supplier_LeadTime_CV
    FROM KPI_Sales s, KPI_Forecast f, KPI_Inventory i, KPI_Suppliers sp;
END;
GO