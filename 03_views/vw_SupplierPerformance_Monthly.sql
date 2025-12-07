USE InventoryAnalytics;
GO

CREATE OR ALTER VIEW sc_inventory.vw_SupplierPerformance AS
SELECT
    [Year],
    [Month],
    Supplier_ID,

    -- network footprint
    COUNT(DISTINCT SKU_ID)          AS SKU_Count,
    COUNT(DISTINCT Warehouse_ID)    AS Warehouse_Count,
    COUNT(DISTINCT Region)          AS Region_Count,

    -- volume and inventory exposure
    SUM(Units_Sold)                 AS Total_Units_Sold,
    AVG(Inventory_Level)            AS AVG_Inventory_Level,

    -- lead time statistis
    AVG(Supplier_Lead_Time_Days)    AS Avg_LeadTime_Days,
    STDEV(Supplier_Lead_Time_Days)  AS LeadTime_StdDev_Days,
    MIN(Supplier_Lead_Time_Days)    AS Min_LeadTime_Days,
    MAX(Supplier_Lead_Time_Days)    AS Max_LeadTime_Days,

    -- Coef of Variation
    CASE 
        WHEN AVG(Supplier_Lead_Time_Days) = 0 THEN NULL
        ELSE STDEV(Supplier_Lead_Time_Days) / AVG(Supplier_Lead_Time_Days)
    END AS LeadTime_CV

FROM sc_inventory.vw_DailyInventory
GROUP BY [Year], [Month], Supplier_ID;
GO

SELECT * FROM sc_inventory.vw_SupplierPerformance;