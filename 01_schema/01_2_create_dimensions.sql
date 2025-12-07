-- DimDate
USE InventoryAnalytics;
GO

IF NOT EXISTS (
    SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID('sc_inventory.DimDate')
        AND type = 'U'
)
BEGIN 
    CREATE TABLE sc_inventory.DimDate (
        DateKey       INT          NOT NULL PRIMARY KEY,  -- e.g. 20240101
        DateValue     DATE         NOT NULL,
        DayOfWeek     TINYINT      NOT NULL,              -- 1–7
        DayName       VARCHAR(10)  NOT NULL,              -- Monday, ...
        DayOfMonth    TINYINT      NOT NULL,              -- 1–31
        WeekOfYear    TINYINT      NOT NULL,              -- 1–53
        Month         TINYINT      NOT NULL,              -- 1–12
        MonthName     VARCHAR(10)  NOT NULL,              -- Jan, Feb, ...
        Quarter       TINYINT      NOT NULL,              -- 1–4
        [Year]        SMALLINT     NOT NULL,
        IsWeekend     BIT          NOT NULL
    );
    PRINT 'Table sc_inventory.DimDate created.';
END
ELSE
BEGIN
    PRINT 'Table sc_inventory.DimDate already exists.';
END;
GO
