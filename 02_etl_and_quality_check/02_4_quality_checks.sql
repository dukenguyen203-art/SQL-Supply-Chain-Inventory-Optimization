USE InventoryAnalytics;
GO

-- Row count sanity check
SELECT 
    (SELECT COUNT(*) FROM sc_inventory.Stg_InventoryDailyRaw)   AS StagingRowCount,
    (SELECT COUNT(*) FROM sc_inventory.FactInventoryDaily)      AS FactRowCount,
    (SELECT COUNT(*) FROM sc_inventory.DimDate)                 AS DimDateRowCount;
GO

-- Date range consistency (should be all same)
SELECT 
    'Staging'    AS Source,
    MIN(DateValue) AS MinDate,
    MAX(DateValue) AS MaxDate
FROM sc_inventory.Stg_InventoryDailyRaw

UNION ALL

SELECT 
    'DimDate',
    MIN(DateValue),
    MAX(DateValue)
FROM sc_inventory.DimDate

UNION ALL

SELECT 
    'Fact',
    MIN(d.DateValue),
    MAX(d.DateValue)
FROM sc_inventory.FactInventoryDaily f
JOIN sc_inventory.DimDate d
    ON f.DateKey = d.DateKey;
GO

-- Check for 'orphan' Fact rows (should be 0 rows)
SELECT TOP (20)
    f.*
FROM sc_inventory.FactInventoryDaily f
LEFT JOIN sc_inventory.DimDate d
    ON f.DateKey = d.DateKey
WHERE d.DateKey IS NULL;
GO

-- Null check on key and important fields (should all be not null)
SELECT 
    SUM(CASE WHEN DateKey       IS NULL THEN 1 ELSE 0 END) AS Null_DateKey,
    SUM(CASE WHEN SKU_ID       IS NULL THEN 1 ELSE 0 END) AS Null_SKU_ID,
    SUM(CASE WHEN Warehouse_ID IS NULL THEN 1 ELSE 0 END) AS Null_Warehouse_ID,
    SUM(CASE WHEN Supplier_ID  IS NULL THEN 1 ELSE 0 END) AS Null_Supplier_ID,
    SUM(CASE WHEN Region       IS NULL THEN 1 ELSE 0 END) AS Null_Region,
    SUM(CASE WHEN Units_Sold   IS NULL THEN 1 ELSE 0 END) AS Null_Units_Sold,
    SUM(CASE WHEN Inventory_Level IS NULL THEN 1 ELSE 0 END) AS Null_Inventory_Level
FROM sc_inventory.FactInventoryDaily;
GO

-- Negative/supicious numeric values
SELECT TOP (50) *
FROM sc_inventory.FactInventoryDaily
WHERE Units_Sold            < 0
   OR Inventory_Level       < 0
   OR Supplier_Lead_Time_Days < 0
   OR Reorder_Point         < 0
   OR Order_Quantity        < 0
   OR Unit_Cost             < 0
   OR Unit_Price            < 0
   OR Demand_Forecast       < 0;
GO

-- Check promotion / stockout flags (should only be 0 or 1)
SELECT 
    Promotion_Flag,
    COUNT(*) AS PromotionRowCount
FROM sc_inventory.FactInventoryDaily
GROUP BY Promotion_Flag;

SELECT 
    Stockout_Flag,
    COUNT(*) AS StockoutRowCount
FROM sc_inventory.FactInventoryDaily
GROUP BY Stockout_Flag;
GO

-- Check duplicate business key (same DateKey + SKU_ID + Warehouse_ID + Supplier_ID should not exists)
SELECT 
    DateKey,
    SKU_ID,
    Warehouse_ID,
    Supplier_ID,
    COUNT(*) AS DuplicateRowCount
FROM sc_inventory.FactInventoryDaily
GROUP BY DateKey, SKU_ID, Warehouse_ID, Supplier_ID
HAVING COUNT(*) > 1
ORDER BY DuplicateRowCount DESC;
GO

-- Distribution overview for key measures
SELECT 
    MIN(Units_Sold)          AS Min_Units_Sold,
    MAX(Units_Sold)          AS Max_Units_Sold,
    AVG(Units_Sold)          AS Avg_Units_Sold,
    MIN(Inventory_Level)     AS Min_Inventory_Level,
    MAX(Inventory_Level)     AS Max_Inventory_Level,
    AVG(Inventory_Level)     AS Avg_Inventory_Level,
    MIN(Demand_Forecast)     AS Min_Demand_Forecast,
    MAX(Demand_Forecast)     AS Max_Demand_Forecast,
    AVG(Demand_Forecast)     AS Avg_Demand_Forecast
FROM sc_inventory.FactInventoryDaily;
GO