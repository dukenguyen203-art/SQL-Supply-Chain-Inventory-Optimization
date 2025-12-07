USE InventoryAnalytics;
GO

-- Create Fact table
IF NOT EXISTS (
    SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID('sc_inventory.FactInventoryDaily') 
      AND type = 'U'
)
BEGIN
    CREATE TABLE sc_inventory.FactInventoryDaily (
        InventoryDailyKey        BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        DateKey                  INT           NOT NULL,
        SKU_ID                   VARCHAR(50)   NOT NULL,
        Warehouse_ID             VARCHAR(50)   NOT NULL,
        Supplier_ID              VARCHAR(50)   NOT NULL,
        Region                   VARCHAR(50)   NOT NULL,
        Units_Sold               DECIMAL(12,2) NOT NULL,
        Inventory_Level          DECIMAL(12,2) NOT NULL,
        Supplier_Lead_Time_Days  DECIMAL(6,2)  NOT NULL,
        Reorder_Point            DECIMAL(12,2) NOT NULL,
        Order_Quantity           DECIMAL(12,2) NOT NULL,
        Unit_Cost                DECIMAL(12,4) NOT NULL,
        Unit_Price               DECIMAL(12,4) NOT NULL,
        Promotion_Flag           BIT           NOT NULL,
        Stockout_Flag            BIT           NOT NULL,
        Demand_Forecast          DECIMAL(12,2) NOT NULL,

        CreatedAt                DATETIME2(0)  NOT NULL DEFAULT SYSDATETIME(),

        CONSTRAINT FK_FactInventoryDaily_DimDate
            FOREIGN KEY (DateKey) REFERENCES sc_inventory.DimDate(DateKey)
    );
    PRINT 'Table sc_inventory.FactInventoryDaily created.';
END;
GO

-- Create helpful index for common queries
IF NOT EXISTS (
    SELECT * FROM sys.indexes
    WHERE name = 'IX_FactInventoryDaily_Date_SKU_WH'
        AND object_id = OBJECT_ID('sc_inventory.FactInventoryDaily')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_FactInventoryDaily_Date_SKU_WH
    ON sc_inventory.FactInventoryDaily (DateKey, SKU_ID, Warehouse_ID);
    PRINT 'Index IX_FactInventoryDaily_Date_SKU_WH created.';
END
ELSE
BEGIN
    PRINT 'Index IX_FactInventoryDaily_Date_SKU_WH already exists';
END;
GO