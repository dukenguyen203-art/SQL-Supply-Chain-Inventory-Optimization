USE InventoryAnalytics;
GO

/*
Q9 Warehouse Demand Surges (MoM Growth)
Business question:
    Which warehouses experience sudden month-on-month spikes in demand?
*/

DECLARE @Year INT = 2024;
DECLARE @MinMonthlyUnits INT = 500; -- filter low volume warehouses
DECLARE @TopN INT = 20;
;WITH MonthlyDemand AS (
    SELECT
        [Year],
        [Month],
        Warehouse_ID,
        Total_Units_Sold
    FROM sc_inventory.vw_ForecastAccuracy_Monthly
    WHERE [Year] = @Year
),
MoM AS (
    SELECT
        Warehouse_ID, 
        [Year],
        [Month],
        Total_Units_Sold,
        LAG(Total_Units_Sold) OVER (
            PARTITION BY Warehouse_ID, [Year] ORDER BY [Month]
        ) AS Prev_Month_Units
        FROM MonthlyDemand
)
SELECT TOP (@TopN)
    Warehouse_ID,
    [Year],
    [Month],
    Prev_Month_Units,
    Total_Units_Sold AS Curr_Month_Units,
    CASE 
        WHEN Prev_Month_Units IS NULL THEN NULL
        WHEN Prev_Month_Units = 0 THEN NULL
        ELSE (Total_Units_Sold - Prev_Month_Units) * 1.0 / Prev_Month_Units
    END AS MoM_Growth
FROM MoM
WHERE Prev_Month_Units > @MinMonthlyUnits
ORDER BY MoM_Growth DESC;
GO

/*
Q10 Network Imbalance Analysis
Business question:
    For each SKU, which warehouses hold significantly more or less inventory than the network average>
*/

DECLARE @Year INT = 2024;
DECLARE @TopN INT = 100;
DECLARE @MinAvgInventory DECIMAL(18,2) = 50.0; -- filter tiny skus
DECLARE @ImbalanceThreshold DECIMAL(10,4) = 0.20; -- 20% imbalance

;WITH SKU_NetworkAvg AS (
    SELECT
        [Year],
        [Month],
        SKU_ID,
        AVG(AvgInventoryLevel) AS Network_Avg_Inventory
    FROM sc_inventory.vw_InventoryHealth_Monthly
    WHERE [Year] = @Year
    GROUP BY [Year], [Month], SKU_ID
),
SKU_Warehouse AS (
    SELECT
        ih.Year,
        ih.Month,
        ih.SKU_ID,
        ih.Warehouse_ID,
        sna.Network_Avg_Inventory,
        ih.AvgInventoryLevel,
        CASE  
            WHEN sna.Network_Avg_Inventory = 0 THEN NULL
            ELSE (ih.AvgInventoryLevel - sna.Network_Avg_Inventory) * 1.0 / sna.Network_Avg_Inventory
        END AS Inventory_Imbalance_Pct
    FROM sc_inventory.vw_InventoryHealth_Monthly ih
    JOIN SKU_NetworkAvg sna
        ON ih.SKU_ID = sna.SKU_ID AND ih.[Year] = sna.[Year] AND ih.[Month] = sna.[Month]
    WHERE ih.Year = @Year
        AND ih.AvgInventoryLevel >= @MinAvgInventory
)
SELECT TOP (@TopN)
    Year,
    Month,
    SKU_ID,
    Warehouse_ID,
    AvgInventoryLevel,
    Network_Avg_Inventory,
    Inventory_Imbalance_Pct,
    CASE 
        WHEN Inventory_Imbalance_Pct IS NULL THEN 'No data'
        WHEN Inventory_Imbalance_Pct >= @ImbalanceThreshold THEN 'Overstocked'
        WHEN Inventory_Imbalance_Pct <= -@ImbalanceThreshold THEN 'Understocked'
        ELSE 'Balanced'
    END AS Imbalance_Flag
FROM SKU_Warehouse
ORDER BY ABS(Inventory_Imbalance_Pct) DESC, AvgInventoryLevel DESC;
GO