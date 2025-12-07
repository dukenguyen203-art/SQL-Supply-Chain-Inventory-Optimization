USE InventoryAnalytics;
GO

CREATE OR ALTER VIEW sc_inventory.vw_DailyInventory AS
SELECT
    f.InventoryDailyKey,
    d.DateValue,
    d.[Year],
    d.[Month],
    d.MonthName,
    d.WeekOfYear,
    f.SKU_ID,
    f.Warehouse_ID,
    f.Supplier_ID,
    f.Region,
    f.Units_Sold,
    f.Inventory_Level,
    f.Supplier_Lead_Time_Days,
    f.Reorder_Point,
    f.Order_Quantity,
    f.Unit_Cost,
    f.Unit_Price,
    Units_Sold * f.Unit_Price     AS Revenue,
    Units_Sold * f.Unit_Cost      AS Cogs,
    f.Promotion_Flag,
    f.Stockout_Flag,
    f.Demand_Forecast
FROM sc_inventory.FactInventoryDaily f
JOIN sc_inventory.DimDate d
    ON f.DateKey = d.DateKey;
GO

SELECT * FROM sc_inventory.vw_DailyInventory;