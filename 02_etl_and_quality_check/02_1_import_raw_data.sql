USE InventoryAnalytics;
GO

-- Clean up staging table before import
DECLARE @StagingRowCount INT;

SELECT @StagingRowCount = COUNT(*)
FROM sc_inventory.Stg_InventoryDailyRaw;

IF @StagingRowCount = 0
BEGIN
    PRINT 'Staging table is clear. Proceed with import...';
END
ELSE
BEGIN
    PRINT CONCAT('Staging table contains ', @StagingRowCount, ' rows. Truncating...');
    TRUNCATE TABLE sc_inventory.Stg_InventoryDailyRaw;
    PRINT 'Staging table truncated successfully. Proceed with import...';
END;
GO

-- Bulk insert raw csv into staging
BEGIN TRY
    BULK INSERT sc_inventory.Stg_InventoryDailyRaw
    FROM "C:\Users\ndngh\Downloads\Project portfolio\SQL Supply Chain Inventory Optimization\data\supply_chain_dataset1.csv"
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

    PRINT 'Raw data successfully imported into staging.';
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    PRINT 'Bulk insert failed: ' + @ErrorMessage
    RETURN;
END CATCH;
GO

-- Row count after load
SELECT COUNT(*) AS StagingRowCount
FROM sc_inventory.Stg_InventoryDailyRaw;
GO