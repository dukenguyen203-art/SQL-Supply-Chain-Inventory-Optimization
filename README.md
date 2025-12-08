# SQL Supply Chain Inventory Optimisation
*Inventory Optimisation - Forecast Accuracy - Operational Insights*

## Overview
This project builds a complete SQL analytics environment to diagnose and optimise supply chain performance using daily operational data. It reproduces an end-to-end analytics workflow commonly found in enterprise systems—transforming raw transactional data into structured insights, operational KPIs, and portfolio-level optimisation signals.

The project blends business analysis with strong SQL engineering, demonstrating how technical systems support clear, data-driven decisions.

## Project Objectives
- Build a fully structured SQL analytics environment for supply chain optimisation.
- Diagnose forecast accuracy, inventory efficiency, supplier reliability, and warehouse performance.
- Transform raw operational data into actionable KPIs, risk indicators, and planning insights.
- Demonstrate scalable SQL engineering practices used in real enterprise analytics systems.
- Provide a repeatable framework for decision support across procurement, planning, and operations.

## Analytical Framework
The analysis focuses on 10 core executive-level business questions, covering:
* Forecast Accuracy
* Inventory Health
* Product Performance
* Warehouse Performance
* Supplier Performance

**Full analysis:**
- [04_analysis/analysis_report.md](04_analysis/analysis_report.md)

**Supporting SQL queries:**
- [04_analysis/queries](04_analysis/queries)

## Dataset Summary
This project uses the High-Dimensional Supply Chain Inventory Dataset, a realistic simulation of daily SKU-level operations, including sales, inventory movements, replenishment behaviour, supplier lead times, and promotional effects.
* [High-Dimensional Supply Chain Inventory Dataset](https://www.kaggle.com/datasets/ziya07/high-dimensional-supply-chain-inventory-dataset)

Key Features:
- Daily timestamps across one year
- SKU-level detail with varied demand patterns
- Multi-warehouse, multi-region distribution
- Units sold, promotions, and stockout indicators
- Dynamic inventory levels and replenishment logic
- Supplier lead-time variability
- Unit cost, selling price, and revenue
- Forecasted demand for accuracy evaluation

The dataset provides a rich base for analysing operational efficiency across product, warehouse, and supplier dimensions.

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
- [04_analysis/analysis_report.md](04_analysis/analysis_report.md)

## Deliverables
- SQL Database Schema (fact/dimension model, staging layer, indexing)
- ETL Pipeline & Data Quality Checks (automated loading + validation scripts)
- Analytics Layer (Views) supporting monthly forecasting, inventory, supplier, and warehouse KPIs
- Reusable Analytical Components
  - ABC–XYZ classification function
  - Executive KPI stored procedure
- 10-Theme Insight Report addressing forecasting, inventory, supplier, product, and warehouse questions
- Documentation including structured analysis, query library, folder hierarchy, and README

## Technical Skills Demonstrated
- Data Engineering
  - Dimensional modelling (fact–dimension)
  - ETL pipeline construction & QC checks
  - Indexing and performance tuning
- Analytical SQL
  - Window functions, aggregations, roll-ups
  - Forecast metrics: WAPE, MAPE
  - Inventory KPIs: DOH, Turnover, Volatility
  - ABC–XYZ classification logic
- Procedures & Functions
  - Table-valued functions
  - Parameter-driven stored procedures
  - Modular analytical components
##  Key Insights
- Forecast accuracy weakens in the second half of the year, especially Aug–Nov, leading to rising WAPE and increased reliance on inventory buffers.
- Demand volatility is moderate and consistent across SKUs, meaning revenue contribution—not variability—is the key driver for prioritisation.
- Inventory distribution is uneven across the network, with several warehouses holding 30–45% above or below the network average for the same SKU in the same month.
- Slow-moving stock accumulates, with DOH frequently exceeding 60–75 days, tying up significant working capital.
- Supplier lead-time variability is universally high, not concentrated in a small subset, increasing systemic supply risk.
- Warehouses show recurring seasonal surges, indicating predictable but unmodelled peak periods.
- Revenue and consumption value are broadly distributed, with no extreme concentration—most SKUs and suppliers contribute meaningfully to financial outcomes.

## Recommendations
- Implement a mid-year reforecast cycle to address rising WAPE and shifting demand patterns.
- Prioritise high-volume, high-WAPE SKUs for forecast and service-level improvements, since the portfolio lacks a small “critical top tier.”
- Stabilise supplier lead times, as variability is widespread and inflates safety stock requirements.
- Optimise inventory distribution across warehouses, using imbalance metrics to lift service while reducing excess.
- Design replenishment policies that scale across a wide SKU portfolio, since low-impact items are limited.
- Introduce seasonal uplifts into forecasting, especially for warehouses with consistent demand peaks.

## Folder structure
- /data/                               → Raw dataset
- /01_schema/                          → DB, schema, tables, indexes
- /02_etl_and_quality_check/           → Import, staging, DimDate, Fact load, QC
- /03_views/                           → Semantic/analytics layer
- /04_analysis/
      - analysis_report.md             → Full analysis
      - /queries/                      → SQL files per business question
      - analysis_report.md
- /05_functions_stored_procedures/     → ABC–XYZ & KPI components
- /README.md/

## Setup Instructions
1. Configure dataset path**
  - Update the file path in: `02_etl_and_quality_check/01_import_raw_data.sql`
2. Execute in the following order**
  1. `/01_schema/`
  2. `/02_etl_and_quality_check/`
  3. `/03_views/`
  4. `/05_functions_stored_procedures/`
  5. `/04_analysis/` (read only)

## Conclusion
This project demonstrates how SQL can be used to build a robust analytical environment for supply chain operations, integrating:
- Dimensional modelling
- ETL & quality checks
- Analytical views
- Segmentation logic
- Executive KPIs
- Structured business insights

The result is a scalable, transparent, and end-to-end framework for supply chain decision support.

## Author
Duke Nguyen
* Github: [@dukenguyen203-art](https://github.com/dukenguyen203-art)
* LinkedIn: [Duke Nguyen](https://www.linkedin.com/in/duke-n-nguyen/)
