USE InventoryAnalytics;
GO

/*
Q5 Demand Volatile (Demand_CV)
Business question:
    Which SKUs have highly variable demand patterns, making forecasting and replenishment difficult?
*/

DECLARE @Year INT = 2024
DECLARE @MinAnnualUnits INT = 1000; -- eliminate low volume
DECLARE @TopN INT = 50;

;WITH AnnualAgg AS (
    SELECT
        [Year],
        SKU_ID,
        SUM(Total_Units_Sold)   AS AnnualUnits,
        AVG(Demand_CV)          AS Avg_Demand_CV
    FROM sc_inventory.vw_ProductPerformance
    WHERE [Year] = @Year
    GROUP BY [Year],SKU_ID
)
SELECT TOP (@TopN)
    [Year],
    SKU_ID,
    AnnualUnits,
    ROUND(Avg_Demand_CV,2) AS Avg_Demand_CV
FROM AnnualAgg
WHERE AnnualUnits > @MinAnnualUnits
ORDER BY Avg_Demand_CV DESC, AnnualUnits DESC;
GO

/*
Q6 Revenue Pareto / ABC Analysis
Business question:
    Which SKUs contribute most to total revenue, and how can we classify them into A/B/C categories to priorities planning and inventory strategy
*/

DECLARE @Year INT = 2024;

;WITH AnnualRevenue AS (
    SELECT
        [Year],
        SKU_ID,
        SUM(Total_Revenue)  AS Annual_Revenue
    FROM sc_inventory.vw_ProductPerformance
    WHERE [Year] = @Year
    GROUP BY [Year],SKU_ID
),
Ranked AS (
    SELECT
        [Year],
        SKU_ID,
        Annual_Revenue,
        SUM(Annual_Revenue) OVER (ORDER BY Annual_Revenue DESC) AS Cum_Revenue,
        SUM(Annual_Revenue) OVER()                              AS Total_Revenue_All
    FROM AnnualRevenue
),
Pct AS (
    SELECT
        [Year],
        SKU_ID,
        Annual_Revenue,
        100 * Cum_Revenue / NULLIF(Total_Revenue_All,0)      AS Cum_Revenue_Pct
    FROM Ranked
)
SELECT
    [Year],
    SKU_ID,
    Annual_Revenue,
    ROUND(Cum_Revenue_Pct,2) AS Cum_Revenue_Pct,
    CASE 
        WHEN Cum_Revenue_Pct <= 80 THEN 'A'
        WHEN Cum_Revenue_Pct <= 95 THEN 'B'
        ELSE 'C'
    END AS ABC_Class
FROM Pct   
ORDER BY Annual_Revenue DESC;
GO