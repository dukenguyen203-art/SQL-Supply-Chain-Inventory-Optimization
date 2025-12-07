USE InventoryAnalytics;
GO

-- Populate DimDate
-- get date range from staging table
DECLARE @MinDate DATE;
DECLARE @MaxDate DATE;

SELECT
    @MinDate = MIN(DateValue),
    @MaxDate = MAX(DateValue)
FROM sc_inventory.Stg_InventoryDailyRaw;

IF @MinDate IS NULL OR @MaxDate IS NULL
BEGIN
    PRINT 'No dates found in Stg_InventoryDailyRaw. DimDate not poupulated.';
    RETURN;
END;

PRINT CONCAT('Populating DimDate from ', CONVERT(VARCHAR(10), @MinDate, 23), ' to ', CONVERT(VARCHAR(10), @MaxDate, 23));

;WITH DateRange AS (
    SELECT @MinDate as DateValue
    UNION ALL
    SELECT DATEADD(DAY,1,DateValue)
    FROM DateRange
    WHERE Datevalue < @MaxDate
)
INSERT INTO sc_inventory.DimDate (
    DateKey,
    DateValue,
    DayOfWeek,
    DayName,
    DayOfMonth,
    WeekOfYear,
    Month,
    MonthName,
    Quarter,
    [Year],
    IsWeekend
)
SELECT 
    CONVERT(INT, FORMAT(d.DateValue, 'yyyyMMdd')) AS DateKey,
    d.DateValue,
    DATEPART(WEEKDAY, d.DateValue)               AS DayOfWeek,
    DATENAME(WEEKDAY, d.DateValue)               AS DayName,
    DAY(d.DateValue)                             AS DayOfMonth,
    DATEPART(WEEK, d.DateValue)                  AS WeekOfYear,
    MONTH(d.DateValue)                           AS [Month],
    DATENAME(MONTH, d.DateValue)                 AS MonthName,
    DATEPART(QUARTER, d.DateValue)               AS Quarter,
    YEAR(d.DateValue)                            AS [Year],
    CASE WHEN DATEPART(WEEKDAY, d.DateValue) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend
FROM DateRange d
WHERE NOT EXISTS (
    SELECT 1 
    FROM sc_inventory.DimDate dd
    WHERE dd.DateKey = CONVERT(INT, FORMAT(d.DateValue, 'yyyyMMdd'))
)
OPTION (MAXRECURSION 32767);

PRINT 'Dimdate populated successfully.'
GO
