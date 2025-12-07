USE InventoryAnalytics;
GO

/*
Q7 Supplier Lead Time Variability
Business question:
    Which suppliers have unstable lead times (high LeadTime_CV), especially when they supply large volumes?
*/

DECLARE @Year INT = 2024;
DECLARE @MinAnnualUnits INT = 2000; -- filter low volume suppliers
DECLARE @TopN INT = 10;

;WITH SupplierAnnual AS (
    SELECT
        [Year],
        Supplier_ID,
        SUM(Total_Units_Sold)      AS AnnualUnits,
        AVG(Avg_LeadTime_Days)              AS Avg_LeadTime,
        AVG(LeadTime_CV)         AS Avg_LeadTime_CV
    FROM sc_inventory.vw_SupplierPerformance
    WHERE [Year] = @Year
    GROUP BY [Year], Supplier_ID
)
SELECT TOP (@TopN)
    [Year],
    Supplier_ID,
    AnnualUnits,
    ROUND(Avg_LeadTime,2)      AS Avg_LeadTime,
    ROUND(Avg_LeadTime_CV,2)   AS Avg_LeadTime_CV
FROM SupplierAnnual
WHERE AnnualUnits >= @MinAnnualUnits
ORDER BY Avg_LeadTime_CV DESC, AnnualUnits DESC;
GO

/*
Q8 Supplier ABC Analysis
Business question:
    Which suppliers contribute the most to total inventory value, and how do their lead times compare?
*/

DECLARE @Year INT = 2024;

;WITH SupplierValue AS (
    SELECT
        [Year],
        Supplier_ID,
        SUM(Cogs) AS Annual_Consumption_Value
    FROM sc_inventory.vw_DailyInventory
    WHERE [Year] = @Year
    GROUP BY [Year], Supplier_ID
), 
RankedSuppliers AS (
    SELECT
        [Year],
        Supplier_ID,
        Annual_Consumption_Value,
        SUM(Annual_Consumption_Value) OVER (ORDER BY Annual_Consumption_Value) AS CumConsumptionValue,
        SUM(Annual_Consumption_Value) OVER () AS TotalConsumptionValue
    FROM SupplierValue
),
Pct AS (
    SELECT
        [Year],
        Supplier_ID,
        Annual_Consumption_Value,
        CumConsumptionValue / TotalConsumptionValue *100 AS CumPct
    FROM RankedSuppliers
),
SupplierLeadTime AS (
    SELECT
        [Year],
        Supplier_ID,
        AVG(Avg_LeadTime_Days) AS Avg_LeadTime_Days,
        AVG(LeadTime_CV) AS Avg_LeadTime_CV
    FROM sc_inventory.vw_SupplierPerformance
    WHERE [Year] = @Year
    GROUP BY [Year], Supplier_ID
)
SELECT
    p.[Year],
    p.Supplier_ID,
    p.Annual_Consumption_Value,
    ROUND(p.CumPct,2) AS CumPct,
    CASE 
        WHEN p.CumPct <= 80 THEN 'A'
        WHEN p.CumPct <= 95 THEN 'B'
        ELSE 'C'
    END AS ABC_Class,
    Avg_LeadTime_Days,
    Avg_LeadTime_CV
FROM Pct p
LEFT JOIN SupplierLeadTime sp
    ON p.[Year] = sp.[Year] AND p.Supplier_ID = sp.Supplier_ID
ORDER BY p.CumPct ASC;
GO