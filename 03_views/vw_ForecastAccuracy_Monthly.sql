USE InventoryAnalytics;
GO

CREATE OR ALTER VIEW sc_inventory.vw_ForecastAccuracy_Monthly AS 
WITH DailyError AS (
    SELECT
        DateValue,
        [Year],
        [Month],
        SKU_ID,
        Warehouse_ID,
        Units_Sold,
        Demand_Forecast,
        ABS(Units_Sold - Demand_Forecast)   AS AbsError,
        CASE 
            WHEN Units_Sold >0
                THEN ABS(Units_Sold - Demand_Forecast) / Units_Sold * 100 
            ELSE NULL
        END                                 AS AbsPctError
    FROM sc_inventory.vw_DailyInventory
)
SELECT
    [Year],
    [Month],
    SKU_ID,
    Warehouse_ID,
    SUM(Units_Sold)         AS Total_Units_Sold,
    SUM(Demand_Forecast)    AS Total_Demand_Forecast,
    AVG(AbsError)  AS MAE,
    AVG(AbsPctError)        AS MAPE,
    SUM(AbsError) / NULLIF(SUM(Units_Sold),0) *100 AS WAPE 
FROM DailyError
GROUP BY [Year], [Month], SKU_ID, Warehouse_ID
GO

SELECT * FROM sc_inventory.vw_ForecastAccuracy_Monthly