USE InventoryAnalytics;
GO

/*
Q1 High=Impact Forecast Error (WAPE Hotspots)
Business question:
    Which SKU–Warehouse–Month combinations have the highest weighted forecast error (WAPE), and how much volume do they possess and sell?
*/
DECLARE @TopN INT = 50;
DECLARE @MinSaleVolme INT = 300; -- ignore tiny volume

SELECT TOP(@TopN)
    f.[Year],
    f.[Month],
    f.SKU_ID,
    f.Warehouse_ID,
    f.WAPE,
    i.AvgInventoryLevel,
    i.EndingInventory,
    f.Total_Units_Sold,
    f.Total_Demand_Forecast
FROM sc_inventory.vw_ForecastAccuracy_Monthly AS f
JOIN sc_inventory.vw_InventoryHealth_Monthly AS i
    ON f.[Year] = i.[Year] AND f.[Month] = i.[Month] 
    AND f.SKU_ID = i.SKU_ID AND f.Warehouse_ID = i.Warehouse_ID
WHERE Total_Units_Sold >= @MinSaleVolme
ORDER BY f.WAPE DESC, f.Total_Units_Sold DESC;
GO

/*
Q2 Forecast Trend Over Time
Business question:
    Is forecast accuracy improving or worsening throughout the year for important SKUs, are there patterns of consisten over/under-forecast?
*/

DECLARE @Year INT = 2024;
DECLARE @TopN INT = 10; 

;WITH AnnualVolume AS (
    SELECT
        SKU_ID,
        SUM(Total_Units_Sold) AS AnnualUnits
    FROM sc_inventory.vw_ForecastAccuracy_Monthly
    WHERE [Year] = @Year
    GROUP BY SKU_ID
), 
SKU_RANK AS (
    SELECT
        SKU_ID,
        RANK() OVER (ORDER BY AnnualUnits DESC) AS SKU_Rank
    FROM AnnualVolume
),
Filtered AS (
    SELECT
        fa.Year,
        fa.Month,
        fa.SKU_ID,
        fa.Warehouse_ID,
        fa.Total_Units_Sold,
        fa.Total_Demand_Forecast,
        fa.WAPE,
        (fa.Total_Demand_Forecast - fa.Total_Units_Sold) AS Forecast_Bias
    FROM sc_inventory.vw_ForecastAccuracy_Monthly fa
    JOIN SKU_RANK sr
        ON fa.SKU_ID = sr.SKU_ID
    WHERE fa.Year = @Year
        AND sr.SKU_Rank <= @TopN
),
Trend AS ( 
    SELECT
        SKU_ID,
        [Month],
        AVG(WAPE) AS Avg_Monthly_WAPE,
        SUM(Forecast_Bias) AS Total_Bias
    FROM Filtered
    GROUP BY SKU_ID, [Month]
)
SELECT 
    SKU_ID,
    [Month],
    Avg_Monthly_WAPE,
    Total_Bias,
    CASE 
        WHEN Total_Bias >0 THEN 'Net Over-forecast'
        WHEN Total_Bias <0 THEN 'Net Under-forecast'
        ELSE 'Balanced'
    END AS Forecast_Bias_Direction
FROM Trend
ORDER BY SKU_ID, [Month];
GO



    

