USE InventoryAnalytics;
GO

CREATE OR ALTER VIEW sc_inventory.vw_ProductPerformance AS
WITH Daily AS (
    SELECT
        [Year],
        [Month],
        SKU_ID,
        Supplier_ID,
        Region,
        Warehouse_ID,
        Units_Sold,
        Units_Sold * Unit_Price         AS Revenue,
        Units_Sold * Unit_Cost          AS Cogs,
        Inventory_Level,
        Inventory_Level * Unit_Cost     AS InventoryCost,
        Unit_Price,
        Unit_Cost,
        CASE
            WHEN Unit_Cost > 0 
                THEN (Unit_Price - Unit_Cost) / Unit_Cost * 100
            ELSE NULL
        END AS Profit_Margin,
        Promotion_Flag,
        DateValue
    FROM sc_inventory.vw_DailyInventory
), PromoLift AS (
    SELECT
        [Year],
        [Month],
        SKU_ID,
        SUM(Units_Sold) AS Total_Units_Sold,
        COUNT(DISTINCT DateValue) AS No_of_Days,
        SUM(CASE WHEN Promotion_Flag = 1 THEN Units_Sold ELSE 0 END ) AS Promo_Units_Sold,
        SUM(CASE WHEN Promotion_Flag = 0 THEN Units_Sold ELSE 0 END ) AS Regular_Units_Sold,
        SUM(CASE WHEN Promotion_Flag = 1 THEN 1 ELSE 0 END ) AS Promo_Days,
        SUM(CASE WHEN Promotion_Flag = 0 THEN 1 ELSE 0 END ) AS Regular_Days
    FROM Daily
    GROUP BY [Year], [Month], SKU_ID
), Agg AS (
    SELECT
        [Year],
        [Month],
        SKU_ID,
        
        -- network foorprint
        COUNT(DISTINCT Warehouse_ID)      AS Warehouse_Count,
        COUNT(DISTINCT Region)            AS Region_Count,
        COUNT(DISTINCT Supplier_ID)       AS Supplier_Count,

        -- demand, revenue, and other financial statistics
        AVG(Unit_Price)                   AS Avg_Unit_Price,
        AVG(Unit_Cost)                    AS Avg_Unit_Cost,
        AVG(Profit_Margin)                  AS Avg_Profit_Margin,
        SUM(Revenue)                      AS Total_Revenue,
        SUM(Cogs)                         AS Total_COGS,
        SUM(Revenue) - SUM(Cogs)        AS Gross_Profits,

        -- demand variabilty
        STDEV(Units_Sold)                 AS Demand_StdDev,
        AVG(Units_Sold)                     AS Avg_Daily_Demand,
        STDEV(Units_Sold) / AVG(Units_Sold)           AS Demand_CV
    FROM Daily
    GROUP BY [Year], [Month], SKU_ID
)
SELECT
    a.[Year],
    a.[Month],
    a.SKU_ID,
        
    -- network foorprint
    a.Warehouse_Count,
    a.Region_Count,
    a.Supplier_Count,

    -- demand, revenue, and other financial statistics
    a.Avg_Unit_Price,
    a.Avg_Unit_Cost,
    a.Avg_Profit_Margin,
    a.Total_Revenue,
    a.Total_COGS,
    a.Gross_Profits,

    p.Total_Units_Sold,
    
    -- promo
    p.Promo_Units_Sold / p.Total_Units_Sold * 100   AS Promo_Units_Sold_Pct,
    p.Promo_Days / p.No_of_Days * 100               AS Promo_Days_Pct,

    -- demand variabilty
    a.Demand_StdDev,
    a.Avg_Daily_Demand,
    a.Demand_CV
FROM Agg AS a
JOIN PromoLift AS p 
    ON a.[Year] = p.[Year] AND a.[Month] = p.[Month] AND a.SKU_ID = p.SKU_ID;
GO

SELECT * FROM sc_inventory.vw_ProductPerformance


