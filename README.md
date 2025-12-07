# SQL Supply Chain Inventory Optimisation
*Inventory Optimisation - Forecast Accuracy - Operational Insights*

## Overview
This project develops a complete SQL analytics environment to diagnose and optimize supply chain performance using daily operational data. It reproduces an end-to-end analytics process commonly found in real enterprise systems - transforming raw transactional data into structured insights, operational KPIs, risk scoring, and segmentation models.

The project emphasizes business analysis supported by strong SQL engineering, and demonstrates how technical systems can enable clear, data-driven decision making.

## Analytical Framework
The analysis focuses on 10 core executive-level business questions, covering:
* Forecast Accuracy
* Inventory Health
* Product Performance
* Warehouse Performance
* Supplier Performance

**Full analysis:**

**Supporting SQL queries:**

## Dataset Summary
This project uses the **High-Dimensional Supply Chain Inventory Dataset**, which simulates real-world operations with daily, SKU-level data capturing sales, inventory levels, supplier lead times, replenishment behavior, regional distribution, and promotional effects.
* [High-Dimensional Supply Chain Inventory Dataset](https://www.kaggle.com/datasets/ziya07/high-dimensional-supply-chain-inventory-dataset)

Key fields:
Key Features
- Date: Daily timestamps spanning one year of activity.
- SKU-Level Detail: Unique product identifiers with varying demand patterns.
- Warehouse and Region: Spatial dimensions representing distribution networks.
- Units Sold: Simulated sales data with seasonal trends and random noise.
- Inventory Levels: Dynamic on-hand stock that evolves over time.
- Supplier Lead Times: Variable delivery delays for replenishment orders.
- Reorder Points and Quantities: Inventory policy thresholds and simulated replenishments.
- Promotions: Binary indicator of promotional periods influencing demand.
- Stockout Events: Flags indicating when demand exceeds available inventory.
- Supplier Information: Links products to specific suppliers with unique lead times.
- Cost and Price: Realistic unit costs and selling prices with profit margins.
- Forecasted Demand: Approximate prediction values reflecting planning estimates.

The dataset provides a complete base for evaluating operational efficiency across time and across product, warehouse, and supplier dimensions.

# Project Workflow
1. Schema & Data Architecture
- Create database, schema, fact and dimension structures
- Implement star schema with date key and nonclustered index
- Define staging and analytical layers
2. Data Loading & Quality Checks
- Bulk load raw CSV into staging
- Validate structure, datatypes, and ranges
- Check grain, duplicates, nulls, outliers
- Automated DimDate generation (min–max window)
- Load FactInventoryDaily with integrity checks
3. Analytics Layer (Views)
- Curated SQL views to support business analysis:
  - Daily activity (vw_DailyInventory)
  - Monthly inventory health
  - Forecast accuracy
  - Product performance
  - Supplier performance
  - Warehouse performance
4. Advanced Analytical Components
- Reusable analytical logic:
  - ABC–XYZ segmentation function (fn_ABCXYZ)
  - Executive KPI procedure (usp_KPIs_Period)
  - Classification based on cumulative share and variability
  - KPI calculation for any date period
5. Key Insights (10 Business Questions)
- Ten executive-level insight themes, including:
  - Inventory DOH & turnover performance
  - Forecast quality & risk areas
  - Slow-moving items
  - SKU contribution analysis
  - Supplier reliability
  - Warehouse operational efficiency
  - Excess stock identification
  - ABC–XYZ strategic portfolio segmentation

Full analysis is stored in:
- /04_analysis/analysis_report.md

## Technical Skills Demonstrated
- Data Engineering
  - Dimensional modeling (fact–dimension)
  - Bulk loading & ETL pipelines
  - Data type enforcement, QC checks, cleansing
  - Star schema design with DateKey
  - Performance tuning with nonclustered indexes
- Analytical SQL
  - Window functions (SUM OVER, STDEV, PERCENTILE_RANK)
  - Time-based rollups (weekly/monthly aggregation)
  - Forecast accuracy metrics (MAPE, WAPE)
  - DOH, turnover, volatility calculations
  - ABC and XYZ classification logic
- Procedures & Functions
  - Table-valued functions
  - Stored procedures with runtime parameters
  - Reusable analytics via modular SQL components
##  Key Insights
## Folder structure
- /data/                               → Raw dataset
- /01_schema/                          → DB, schema, tables, indexes
- /02_etl_and_quality_check/           → Import, staging, DimDate, Fact load, QC
- /03_views/                           → Semantic/analytics layer
- /04_analysis/
      - analysis_report.md           → Full analysis
      - /queries/                      → SQL files per business question
- /05_functions_stored_procedures/     → ABC–XYZ & KPI components
- /README.md/
## Setup Instructions
**Configure dataset path**

Update the file path in:
`02_etl_and_quality_check/01_import_raw_data.sql`

**Execute in the following order**
1. `/01_schema/`
2. `/02_etl_and_quality_check/`
3. `/03_views/`
4. `/05_functions_stored_procedures/`
5. `/04_analysis/` (read only)

## Conclusion
This project demonstrates how SQL can be used to build a complete analytical environment for supply chain operations.

It integrates:
- dimensional modeling
- ETL & data quality
- analytical views
- segmentation logic
- executive KPIs
- structured business insights

Resulting in a robust, scalable, and transparent analytics solution.

## Author
Duke Nguyen
* Github: [@dukenguyen203-art](https://github.com/dukenguyen203-art)
* LinkedIn: [Duke Nguyen](https://www.linkedin.com/in/duke-n-nguyen/)
