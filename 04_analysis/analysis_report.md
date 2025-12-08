# Supply Chain Inventory Analysis Report

## Executive Summary
This project explores how demand, inventory, suppliers, and warehouse operations interact across a full supply chain network. 
The analysis highlights five key areas influencing performance: forecast accuracy, inventory health, supplier reliability, warehouse behaviour, and SKU portfolio structure.

Across the network, a consistent pattern emerges: forecasts become less reliable in the second half of the year, inventory rises to compensate, and supplier lead-time variability adds pressure to stock levels. 
Warehouses experience moderate but recurring demand surges, and inventory is not always distributed in line with actual demand patterns.

These insights collectively point to opportunities in reforecasting cycles, replenishment logic, supplier management, and network balancing. 
The outcome is a clearer understanding of where the supply chain holds excess working capital, where risks accumulate, and where targeted improvements will deliver the strongest operational and financial impact.
## Analytical Framework
The analysis follows a structured, question-driven approach aligned to typical supply chain analytics workflows:
- Forecast Diagnostics
  - Examined WAPE, bias, and demand trends by SKU and warehouse to identify accuracy gaps and seasonal challenges.
- Inventory Health Review
  - Assessed DOH, turnover, slow movers, and volatility to understand where inventory is over- or under-performing.
- Supplier Reliability Assessment
  - Measured average lead times and LeadTime_CV to evaluate how supplier variability influences safety stock and service levels.
- Warehouse & Network Evaluation
  - Reviewed demand surges, deployment imbalances, and stock distribution to detect operational pressure points and inefficiencies.
- Portfolio Structuring (ABC/XYZ Logic)
  - Classified SKUs using revenue contribution and demand volatility to define differentiated planning and service strategies.

This framework ensures the insights are not isolated observations but part of a coherent view of how forecasting, inventory, suppliers, and network operations shape overall performance.

## Analysis
### 1. Forecast Accuracy & Demand Behaviour
This section explores how demand forecasts performed across SKUs and warehouses, and how demand behaved month-to-month.
#### 1.1 Forecast Error Hotspots (WAPE)
High WAPE values (≈25–33%) were concentrated among medium–high volume SKUs. These errors occurred most frequently in August–November, suggesting late-year demand is harder to predict.

Even though forecasts were inaccurate, inventory levels remained high, indicating that the network protects service with stock rather than reliable demand signals.

Key points:
- Late-year months consistently show higher forecast errors.
- Many hotspots involve SKUs selling 400–700 units per month—errors with real financial impact.
- Mixed bias patterns (both over- and under-forecasting) hint at unstable demand behaviour rather than systematic bias alone.

References:
- Query Code: [`queries/04_1_Forecast_Accuracy_Analysis.sql`](./queries/04_1_Forecast_Accuracy_Analysis.sql)
- Result File: [`results/Q1 High-Impact Forecast Error (WAPE Hotspots).csv`](./results)

#### 1.2 Forecast Trend Over Time
Across top SKUs, WAPE increases steadily through the year:
- Jan–Apr: 7–11%
- Jul–Oct: 15–25%+
Several SKUs show recognizable bias patterns. Some consistently under-forecast early and over-forecast later, while others persistently lean one way.

Implications:
- Adjustments or recalibration should occur mid-year to reflect evolving demand patterns.
- Certain SKUs require closer monitoring for bias.

References:
- Query Code: [`queries/04_1_Forecast_Accuracy_Analysis.sql`](./queries/04_1_Forecast_Accuracy_Analysis.sql)
- Result File: [`results/Q2 Forecast Trend Over Time`](./results)

#### 1.3 Demand Volatility (CV)
Demand_CV for all major SKUs clusters tightly around 0.31–0.33.
This indicates:
- Medium volatility across the board
- No extreme outliers
- A portfolio that behaves uniformly from a planning standpoint

This means prioritisation should focus more on revenue contribution, forecasting error, and inventory behaviour, rather than demand variability alone.

References:
- Query Code: [`queries/04_3_Product_Performance_Analysis.sql`](./queries/04_3_Product_Performance_Analysis.sql)
- Result File: [`results/Q5 Demand Volatile (Demand_CV).csv`](./results)

#### 1.4 Warehouse Demand Surges
Warehouses commonly experience moderate MoM surges of 15–22%, especially:
- WH_1 in December
- WH_3 and WH_5 in March
- WH_5 again in December
- WH_2 in July

This pattern suggests seasonal or promotional cycles that should be explicitly modelled in forecasts and staffing plans.
<img width="1022" height="962" alt="image" src="https://github.com/user-attachments/assets/015ff891-352b-4bce-8348-9f7bb9ffa103" />

References:
- Query Code: [`queries/04_5_Warehouse_Performance_Analysis.sql`](./queries/04_5_Warehouse_Performance_Analysis.sql)
- Result File: [`results/Q9 Warehouse Demand Surges (MoM Growth).csv`](./results)

### 2. Inventory Health & Working Capital
An examination of stock levels, slow-movers, DOH, and replenishment behaviour.

#### 2.1 Slow Movers & DOH
Several SKU–Warehouse combinations have 60–75+ days of inventory with modest sales. Many of these appear in September–October, indicating over-preparation for demand that did not occur as expected.
Common characteristics of slow movers:
- High AvgInventory (500–650 units)
- Monthly sales around 230–320 units
- Low turnover ratios (~0.40–0.53)

These items represent significant working capital tied up in slow-moving stock.

References:
- Query Code: [`queries/04_2_Inventory_Health_Analysis.sql`](./queries/04_2_Inventory_Health_Analysis.sql)
- Result File: [`results/Q3 Slow Movers (High DOH + Low Turnover).csv`](./results)
 
#### 2.2 Inventory Volatility
Although not extreme, several SKU–Warehouse pairs show medium volatility (Volatility_Index ~0.35–0.41), meaning inventory levels fluctuate more than expected.

Volatility often represents:
- Inconsistent replenishment
- Manual overrides
- Unstable ordering patterns

This instability adds operational noise and can inflate DOH if not controlled.
<img width="1389" height="500" alt="image" src="https://github.com/user-attachments/assets/1442fd39-5888-4c92-94be-0b3f4e1f957e" />

References:
- Query Code: [`queries/04_2_Inventory_Health_Analysis.sql`](./queries/04_2_Inventory_Health_Analysis)
- Result File: [`results/Q4 Excess Inventory by Warehouse.csv`](./results)
 
### 3. Supplier Performance & Lead-Time Stability
Supplier behaviour plays a major role in overall inventory planning.

#### 3.1 Lead-Time Variability
Average lead times are generally stable at 7–8.6 days, but variability is high:
- SUP_7 has the highest variability (CV ~0.60).
- Several other suppliers fall in the 0.45–0.51 range.

Given these are high-volume suppliers, this variability directly increases the need for safety stock.

References:
- Query Code: [`queries/04_4_Supplier_Performance_Analysis.sql`](./queries/04_4_Supplier_Performance_Analysis.sql)
- Result File: [`results/Q7 Supplier Lead Time Variability.csv`](./results)
 
#### 3.2 Supplier ABC (Consumption Value)
Consumption value is concentrated across a small number of suppliers:
- A-class: first 8 suppliers (~74% of value)
- B-class: SUP_7 (large and highly variable)
- C-class: SUP_8 (still large in value)

This means supplier risk is tightly concentrated: the biggest suppliers are also among the most variable.
<img width="1300" height="509" alt="image" src="https://github.com/user-attachments/assets/94dee41b-4b27-48b5-8c5a-d8d20a2f1080" />

References:
- Query Code: [`queries/04_4_Supplier_Performance_Analysis.sql`](./queries/04_4_Supplier_Performance_Analysis.sql)
- Result File: [`results/Q8 Supplier ABC Analysis.csv`](./results)
 
### 4. Warehouse Performance & Network Balance
The network-level distribution of inventory highlights both operational strengths and structural imbalances.

#### 4.1 Imbalance Between Warehouses
Many SKUs show significant overstock or understock relative to network averages:
- Overstock up to +45–46%
- Understock as low as –33–37%

These patterns suggest uneven deployment rather than true regional demand differences.

Effects:
- Excess working capital where not needed
- Increased stockout risk at understocked sites
- Missed opportunities for redistribution (instead of new POs)
<img width="1352" height="955" alt="image" src="https://github.com/user-attachments/assets/c66c1916-157b-44e5-8cc8-761750582e5e" />

References:
- Query Code:[`queries/04_5_Warehouse_Performance_Analysis.sql`](./queries/04_5_Warehouse_Performance_Analysis.sql)
- Result File: [`results/Q10 Network Imbalance Analysis.csv`](./results)
 
### 5. SKU Portfolio Structure (Revenue-Based ABC)
Revenue contribution varies widely, even though volumes do not.

#### 5.1 ABC Classification
About 74% of SKUs (37 out of 50) fall into A-class, contributing ~80% of revenue.
C-class is small (only 4 SKUs) and low-impact, making these prime candidates for simplified stocking.

Because demand volatility is uniform (Y-class), the strongest differentiator becomes:
- Revenue importance (ABC)
- Forecast behaviour (WAPE, bias)
- Inventory performance (DOH, slow movers)
<img width="917" height="971" alt="image" src="https://github.com/user-attachments/assets/25c70d7d-1936-4c15-b57e-416e20530119" />

References:
- Query Code: [`queries/04_3_Product_Performance_Analysis.sql`](./queries/04_3_Product_Performance_Analysis.sql)
- Result File: [`results/Q6 SKU ABC Analysis.csv`](./results)
 
## Integrated Insights
Across all dimensions, the data paints a consistent picture:
- Forecast accuracy weakens later in the year, while inventories rise.
- Inventory is not optimally distributed, creating both overstock and stockout risks.
- Supplier lead-time variability forces higher safety stock and contributes to volatility.
- Warehouse demand patterns are seasonal, yet forecasts and replenishment do not fully account for it.
- SKU importance is driven by revenue, not volume, emphasising the need for ABC-based planning.

## Improvement Opportunities (High-Level)
A few practical steps emerge from the analysis:
- Introduce a mid-year reforecasting cycle for A-class items.
- Establish a slow-mover watchlist (DOH > 60 days).
- Stabilise replenishment patterns for volatile SKUs.
- Use network balance dashboards to guide stock transfers and prevent unnecessary POs.
- Work with high-variability suppliers to tighten delivery windows or adjust safety stock policies.
- Apply ABC–CV logic to allocate planning effort and set differentiated service levels.
