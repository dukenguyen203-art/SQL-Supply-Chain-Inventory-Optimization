USE InventoryAnalytics;
GO

CREATE OR ALTER VIEW sc_inventory.vw_InventoryHealth_Monthly AS
WITH Daily AS (
    SELECT
        d.[Year],
        d.[Month],
        v.SKU_ID,
        v.Warehouse_ID,
        v.Inventory_Level,
        v.Units_Sold,
        v.DateValue,
        v.Unit_Cost,
        ROW_NUMBER() OVER (
            PARTITION BY d.[Year], d.[Month], v.SKU_ID, v.Warehouse_ID
            ORDER BY v.DateValue ASC
        ) AS rn_start,
        ROW_NUMBER() OVER (
            PARTITION BY d.[Year], d.[Month], v.SKU_ID, v.Warehouse_ID
            ORDER BY v.DateValue DESC
        ) AS rn_end
    FROM sc_inventory.vw_DailyInventory v
    JOIN sc_inventory.DimDate d
        ON v.DateValue = d.DateValue
),
Agg AS (
    SELECT
        [Year],
        [Month],
        SKU_ID,
        Warehouse_ID,
        AVG(Inventory_Level) AS AvgInventoryLevel,
        SUM(Units_Sold)      AS TotalUnitsSold,
        AVG(Units_Sold)      AS AvgDailyDemand,
        AVG(Unit_Cost)      AS AvgUnitCost,
        COUNT(*)             AS Days_In_Month,
        STDEV(Inventory_Level) AS Inventory_StdDev,
        MAX(CASE WHEN rn_start = 1 THEN Inventory_Level END) AS BeginningInventory,
        MAX(CASE WHEN rn_end   = 1 THEN Inventory_Level END) AS EndingInventory
    FROM Daily
    GROUP BY [Year], [Month], SKU_ID, Warehouse_ID
)
SELECT
    [Year],
    [Month],
    SKU_ID,
    Warehouse_ID,
    AvgInventoryLevel,
    AvgUnitCost,
    BeginningInventory,
    EndingInventory,
    TotalUnitsSold,

    -- Inventory Turnover = Total units sold / Avg inventory
    CASE 
        WHEN AvgInventoryLevel = 0 THEN NULL
        ELSE TotalUnitsSold * 1.0 / AvgInventoryLevel
    END AS InventoryTurnover,

    -- DOH = Avg inventory / (Avg daily demand)
    CASE
        WHEN AvgDailyDemand = 0 THEN NULL
        ELSE AvgInventoryLevel / AvgDailyDemand
    END AS DOH,

    -- Volatility = StdDev / Avg inventory
    CASE 
        WHEN AvgInventoryLevel = 0 THEN NULL
        ELSE Inventory_StdDev / AvgInventoryLevel
    END AS Inv_Volatility_Index
FROM Agg;
GO

SELECT * FROM sc_inventory.vw_InventoryHealth_Monthly
