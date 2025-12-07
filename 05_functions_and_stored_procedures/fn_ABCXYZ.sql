USE InventoryAnalytics;
GO

-- Clean up existing function and type if they exist
DROP FUNCTION IF EXISTS sc_inventory.fn_ABCXYZ;
DROP TYPE IF EXISTS sc_inventory.fn_ABCXYZ_Input;

-- Create the table type for the ABC XYZ analysis input
CREATE TYPE sc_inventory.fn_ABCXYZ_Input AS TABLE
(
    ItemKey NVARCHAR(50), -- e.g., SKU_ID, Warehouse_ID, Supplier_ID
    ABCMetric DECIMAL(18,4), -- value used for ABC cumulative share,
    XYZMetric DECIMAL(18,4)  -- value used for XYZ variability
);
GO

-- Create the function to perform ABC XYZ analysis
CREATE OR ALTER FUNCTION sc_inventory.fn_ABCXYZ
(
    @InputTable sc_inventory.fn_ABCXYZ_Input READONLY,
    @ABC_A_Threshold DECIMAL(5,2) = NULL, -- Cumulative share threshold for A category
    @ABC_B_Threshold DECIMAL(5,2) = NULL, -- Cumulative share threshold for B category 
    @XYZ_X_Threshold DECIMAL(5,2) = NULL, -- Variability threshold for X category
    @XYZ_Y_Threshold DECIMAL(5,2) = NULL  -- Variability threshold for Y category
)
RETURNS TABLE
AS
RETURN
WITH Thresholds AS (
    SELECT
        -- ABC thresholds (percent of total cumulative value)
        ABC_A = ISNULL(@ABC_A_Threshold, 80.0),
        ABC_B = ISNULL(@ABC_B_Threshold, 95.0),

        -- XYZ thresholds (percentile of CV distribution, not CV%)
        XYZ_X = ISNULL(@XYZ_X_Threshold, 50.0),
        XYZ_Y = ISNULL(@XYZ_Y_Threshold, 80.0)
),
ABC AS (
    SELECT
        ItemKey,
        ABCMetric,
        SUM(ABCMetric) OVER (ORDER BY ABCMetric DESC) AS CumABCMetric,
        SUM(ABCMetric) OVER () AS TotalABCMetric
    FROM @InputTable
),
XYZ AS (
    SELECT
        ItemKey,
        XYZMetric,
        CUME_DIST() OVER (ORDER BY XYZMetric) AS PercentileRank
    FROM @InputTable
),
Ranked AS (
    SELECT
        a.ItemKey,
        a.ABCMetric,
        (a.CumABCMetric / a.TotalABCMetric) * 100 AS CumPctABC,
        x.XYZMetric,
        PercentileRank * 100 AS Percentile_XYZ
    FROM ABC a
    JOIN XYZ x ON a.ItemKey = x.ItemKey
),
Classified AS (
    SELECT
        r.ItemKey,
        r.ABCMetric,
        r.CumPctABC,
        CASE 
            WHEN r.CumPctABC <= t.ABC_A THEN 'A'
            WHEN r.CumPctABC <= t.ABC_B THEN 'B'
            ELSE 'C'
        END AS ABC_Class,
        r.XYZMetric,
        r.Percentile_XYZ,
        CASE 
            WHEN r.Percentile_XYZ <= t.XYZ_X THEN 'X'
            WHEN r.Percentile_XYZ <= t.XYZ_Y THEN 'Y'
            ELSE 'Z'
        END AS XYZ_Class
    FROM Ranked r
    CROSS JOIN Thresholds t
)
SELECT
    ItemKey,
    ABCMetric,
    ROUND(CumPctABC,2) AS CumPctABC,
    ABC_Class,
    XYZMetric,
    ROUND(Percentile_XYZ,2) AS Percentile_XYZ,
    XYZ_Class,
    ABC_Class + XYZ_Class AS ABC_XYZ_Class
FROM Classified c;
GO
