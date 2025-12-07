USE InventoryAnalytics;
GO

-- sanity check: staging row count
PRINT 'Checking staging row count...';

SELECT COUNT(*) AS StagingRowCount
FROM sc_inventory.Stg_InventoryDailyRaw;
GO

-- clean and load/reload FactInventoryDaily
PRINT 'Trungcating FactInventoryDaily before load/reload...';
TRUNCATE TABLE sc_inventory.FactInventoryDaily;

PRINT 'FactInventoryDaily truncated. Loading data...';

INSERT INTO sc_inventory.FactInventoryDaily (
    DateKey,
    SKU_ID,
    Warehouse_ID,
    Supplier_ID,
    Region,
    Units_Sold,
    Inventory_Level,
    Supplier_Lead_Time_Days,
    Reorder_Point,
    Order_Quantity,
    Unit_Cost,
    Unit_Price,
    Promotion_Flag,
    Stockout_Flag,
    Demand_Forecast
)
SELECT
    d.DateKey,
    s.SKU_ID,
    s.Warehouse_ID,
    s.Supplier_ID,
    s.Region,
    s.Units_Sold,
    s.Inventory_Level,
    s.Supplier_Lead_Time_Days,
    s.Reorder_Point,
    s.Order_Quantity,
    s.Unit_Cost,
    s.Unit_Price,
    CASE WHEN s.Promotion_Flag = 1 THEN 1 ELSE 0 END,
    CASE WHEN s.Stockout_Flag = 1 THEN 1 ELSE 0 END,
    s.Demand_Forecast
FROM sc_inventory.Stg_InventoryDailyRaw s
JOIN sc_inventory.DimDate d
    ON d.DateValue = s.DateValue
WHERE
      s.DateValue IS NOT NULL
  AND s.SKU_ID IS NOT NULL
  AND s.Warehouse_ID IS NOT NULL
  AND s.Supplier_ID IS NOT NULL
  AND s.Region IS NOT NULL
  AND s.Units_Sold      >= 0
  AND s.Inventory_Level >= 0
  AND s.Reorder_Point   >= 0
  AND s.Order_Quantity  >= 0
  AND s.Unit_Cost       >= 0
  AND s.Unit_Price      >= 0
  AND s.Demand_Forecast >= 0;

PRINT CONCAT('FactInventoryDaily loaded. Rows inserted: ', @@ROWCOUNT, '.');
GO