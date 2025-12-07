-- Create Database (if not exists)
IF DB_ID('InventoryAnalytics') IS NULL
BEGIN
    PRINT 'Database does not exists. Creating InventoryAnalytics...';
    CREATE DATABASE InventoryAnalytics;
END
ELSE
BEGIN
    PRINT 'Database InventoryAnalytics already exists.'
END;
GO

USE InventoryAnalytics;
GO

-- Create Schema (if not exists)

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name='sc_inventory')
BEGIN
    EXEC('CREATE SCHEMA sc_inventory');
    PRINT 'Schema sc_inventory created.';
END
ELSE
BEGIN
    PRINT 'Schema sc_inventory already exists.';
END;
GO
