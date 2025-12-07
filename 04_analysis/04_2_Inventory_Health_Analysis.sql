USE InventoryAnalytics;
GO

/*
Q3 Slow Movers (High DOH + Low Turnover)
Business question:
    Which SKU–Warehouse–Month combinations are tying up the most working capital due to slow turnover and high DOH?
*/

DECLARE @TopN INT = 50;
DECLARE @MinAvgInventory DECIMAL(18,2) = 100; -- filter tiny skus

SELECT TOP (@TopN)
    [Year],
    [Month],
    SKU_ID,
    Warehouse_ID,
    AvgInventoryLevel,
    TotalUnitsSold,
    InventoryTurnover,
    DOH
FROM sc_inventory.vw_InventoryHealth_Monthly
WHERE AvgInventoryLevel >= @MinAvgInventory
ORDER BY DOH DESC, InventoryTurnover ASC;
GO

/*
Q4 Excess Inventory by Warehouse
Business question:
    Which warehouse–SKU combinations are most responsible for excessive inventory, and how does this compare to sales demand?
*/

DECLARE @MinAvgInventory DECIMAL(18,2) = 100.0;    -- ignore tiny items
DECLARE @HighVolThreshold DECIMAL(10,4) = 0.60;    -- >= 0.60 = very unstable
DECLARE @MedVolThreshold  DECIMAL(10,4) = 0.30;    -- 0.30–0.60 = moderately unstable
DECLARE @TopN INT = 50;                            -- how many rows to inspect

;WITH RankedVolatility AS (
    SELECT
        Year,
        Month,
        SKU_ID,
        Warehouse_ID,
        AvgInventoryLevel,
        DOH,
        Inv_Volatility_Index,
        CASE 
            WHEN Inv_Volatility_Index IS NULL THEN 'No data'
            WHEN Inv_Volatility_Index >= @HighVolThreshold THEN 'High volatility'
            WHEN Inv_Volatility_Index >= @MedVolThreshold  THEN 'Medium volatility'
            ELSE 'Low volatility'
        END AS Volatility_Risk,
        ROW_NUMBER() OVER (
            ORDER BY Inv_Volatility_Index DESC, AvgInventoryLevel DESC
        ) AS VolatilityRank
    FROM sc_inventory.vw_InventoryHealth_Monthly
    WHERE AvgInventoryLevel >= @MinAvgInventory
      AND Inv_Volatility_Index IS NOT NULL
)
SELECT TOP (@TopN)
    Year,
    Month,
    SKU_ID,
    Warehouse_ID,
    AvgInventoryLevel,
    DOH,
    Inv_Volatility_Index,
    Volatility_Risk
FROM RankedVolatility
ORDER BY Inv_Volatility_Index DESC, AvgInventoryLevel DESC;
GO