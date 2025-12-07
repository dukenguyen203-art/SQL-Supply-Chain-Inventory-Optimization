USE InventoryAnalytics;
GO

-- Demo for ABC XYZ Analysis function (fn_ABCXYZ)
/*
Step 1: Create a ABC XYZ input table variable
Step 2: Populate it with ItemKey, ABCMetric, and XYZMetric
Step 3: Call the fn_ABCXYZ function with the input table and optional thresholds (in percentages)
*/

-- Step 1: Create input table variable
DECLARE @t sc_inventory.fn_ABCXYZ_Input;

-- Step 2: Populate the input table with ItemKey, ABCMetric, and XYZMetric (e.g., SKU_ID, Total_Revenue, Demand_CV)
INSERT INTO @t (ItemKey, ABCMetric, XYZMetric)
SELECT
    SKU_ID AS ItemKey,
    SUM(Total_Revenue) AS ABCMetric,
    AVG(Demand_CV) AS XYZMetric
FROM sc_inventory.vw_ProductPerformance
GROUP BY SKU_ID; 

-- Step 3: Call the fn_ABCXYZ function
SELECT *
FROM sc_inventory.fn_ABCXYZ(
    @t,
    80.0,  -- A threshold
    95.0,  -- B threshold
    50.0,  -- X threshold
    80.0   -- Y threshold
)
ORDER BY ABCMetric DESC;
GO

-- Demo for KPI stored procedure (usp_Get_KPIs_Period)
/*
A: Execute the stored procedure without parameters to get KPIs for the full date range
B: Execute the stored procedure with specific start and end dates
*/

-- A: Full date range
EXEC sc_inventory.usp_Get_KPIs_Period;

-- B: Specific date range
EXEC sc_inventory.usp_Get_KPIs_Period
    @StartDate = '2024-10-01',
    @EndDate   = '2024-12-31'; --- Q4 2024