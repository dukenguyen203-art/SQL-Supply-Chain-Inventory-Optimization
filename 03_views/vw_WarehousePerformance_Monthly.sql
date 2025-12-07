USE InventoryAnalytics;
GO

CREATE OR ALTER VIEW sc_inventory.vw_WarehousePerformance AS
WITH Daily AS (
    SELECT
        [Year],
        [Month],
        Warehouse_ID,
        SKU_ID,
        Supplier_ID,
        Region,
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
        Warehouse_ID,
        SUM(Units_Sold) AS Total_Units_Sold,
        COUNT(DISTINCT DateValue) AS No_of_Days,
        SUM(CASE WHEN Promotion_Flag = 1 THEN Units_Sold ELSE 0 END ) AS Promo_Units_Sold,
        SUM(CASE WHEN Promotion_Flag = 0 THEN Units_Sold ELSE 0 END ) AS Regular_Units_Sold,
        SUM(CASE WHEN Promotion_Flag = 1 THEN 1 ELSE 0 END ) AS Promo_Days,
        SUM(CASE WHEN Promotion_Flag = 0 THEN 1 ELSE 0 END ) AS Regular_Days
    FROM Daily
    GROUP BY [Year], [Month], Warehouse_ID
), Agg AS (
    SELECT
        [Year],
        [Month],
        Warehouse_ID,
        
        -- network foorprint
        COUNT(DISTINCT SKU_ID)            AS SKU_Count,
        COUNT(DISTINCT Region)            AS Region_Count,
        COUNT(DISTINCT Supplier_ID)       AS Supplier_Count,

        -- demand, revenue, and other financial statistics
        SUM(Revenue)                      AS Total_Revenue,
        SUM(Cogs)                         AS Total_COGS,
        SUM(Revenue) - SUM(Cogs)          AS Gross_Profits,
        AVG(Units_Sold)                   AS Avg_Units_Sold,

        -- demand variabilty
        STDEV(Inventory_Level)                 AS Inventory_StdDev,
        AVG(Inventory_Level)                   AS Avg_Inventory_Level,
        STDEV(Inventory_Level) / AVG(Inventory_Level)           AS Inventory_CV
    FROM Daily
    GROUP BY [Year], [Month], Warehouse_ID
)
SELECT
    a.[Year],
    a.[Month],
    a.Warehouse_ID,
        
    -- network foorprint
    a.SKU_Count,
    a.Region_Count,
    a.Supplier_Count,

    -- warehouse statistics
    p.Total_Units_Sold,
    a.Total_Revenue,
    a.Total_COGS,
    a.Gross_Profits,
    a.Gross_Profits / a.Total_Revenue * 100         AS Gross_Margin_Pct,
    a.Avg_Inventory_Level,
    p.Total_Units_Sold / a.Avg_Inventory_Level      AS Inventory_Turnover,
    a.Avg_Inventory_Level / a.Avg_Units_Sold        AS DOH,

    -- promo
    p.Promo_Units_Sold / p.Total_Units_Sold * 100   AS Promo_Units_Sold_Pct,
    p.Promo_Days / p.No_of_Days * 100               AS Promo_Days_Pct,

    -- demand variabilty
    a.Inventory_StdDev,
    a.Inventory_CV
FROM Agg AS a
JOIN PromoLift AS p 
    ON a.[Year] = p.[Year] AND a.[Month] = p.[Month] AND a.Warehouse_ID = p.Warehouse_ID;
GO

SELECT * FROM sc_inventory.vw_WarehousePerformance


