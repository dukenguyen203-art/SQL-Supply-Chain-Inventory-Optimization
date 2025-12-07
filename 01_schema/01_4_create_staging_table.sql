USE InventoryAnalytics;
GO

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID('sc_inventory.Stg_InventoryDailyRaw') 
      AND type = 'U'
)
BEGIN
    CREATE TABLE sc_inventory.Stg_InventoryDailyRaw (
        DateValue                DATE,
        SKU_ID                   VARCHAR(50),
        Warehouse_ID             VARCHAR(50),
        Supplier_ID              VARCHAR(50),
        Region                   VARCHAR(50),
        Units_Sold               DECIMAL(12,2),
        Inventory_Level          DECIMAL(12,2),
        Supplier_Lead_Time_Days  DECIMAL(6,2),
        Reorder_Point            DECIMAL(12,2),
        Order_Quantity           DECIMAL(12,2),
        Unit_Cost                DECIMAL(12,4),
        Unit_Price               DECIMAL(12,4),
        Promotion_Flag           TINYINT,      -- 0/1 in raw
        Stockout_Flag            TINYINT,      -- 0/1 in raw
        Demand_Forecast          DECIMAL(12,2)
    );
    PRINT 'Table sc_inventory.Stg_InventoryDailyRaw created.';
END;
ELSE 
BEGIN
    PRINT 'Table sc_inventory.Stg_InventoryDailyRaw already exsists.';
END;
GO