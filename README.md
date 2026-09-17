# Global Electronics Retailer — SQL Analysis Project

An end-to-end SQL Server analysis of a global electronics retailer's sales, products, customers, and store data — from raw CSV files to a documented set of business insights.

**Dataset:** [Global Electronics Retailer](https://www.kaggle.com/datasets/bhavikjikadara/global-electronics-retailer) (Maven Analytics) — a star-schema dataset with a Sales fact table and Customers, Products, Stores, and Exchange Rates dimension tables (~63K sales records, 2,517 products, 15K+ customers, 67 stores across 8 countries).

**Tools:** Microsoft SQL Server, T-SQL — joins, CTEs, window functions (`RANK`, `LAG`, running totals), `PIVOT`, views, data cleaning with `TRY_CAST`/`REPLACE`.

This project uses SQL to analyze **~63,000 sales records**, **2,500+ products**, and **15,000+ customers** across **67 stores in 8 countries**, to identify revenue and profit trends, product and brand profitability, customer purchasing patterns, and operational performance for a global electronics retailer — entirely through raw SQL queries, with no external BI tool.

---

## TL;DR

- Revenue grew steadily 2016–2019, then dropped in 2020. Revenue and profit move together, so the swings come from **sales volume**, not margin changes.
- **27.7% of products generate 80% of revenue** — nearly half the catalog barely moves the needle.
- Profit margin varies a lot by **category** (13%–61%) and **brand** (21%–59%), but barely at all by **country** (44.6%–49.9%) — profitability is a product/brand story, not a geography story.
- The **Online channel** (~21% of orders and revenue) cut its average delivery time from 7 days to 3 days over five years.
- About 14% of the `Products` table had corrupted data on import due to a CSV-parsing issue — diagnosed and fixed (see [Data Quality Note](#data-quality-note)).

---

## Project Structure

| File | Purpose |
|---|---|
| `01_create_tables.sql` | Database schema — 5 tables with primary/foreign keys |
| `02_data_cleaning.sql` | Cleaning raw text price fields into proper `DECIMAL` columns |
| `03_sales_financials_view.sql` | Core reusable view joining Sales + Products, with revenue/cost/profit in USD |
| `04_revenue_trend_analysis.sql` | Q1 — Monthly/yearly revenue & profit trend |
| `05_profit_margin_analysis.sql` | Q2 — Profit margin by category & brand |
| `06_top_selling_products_analysis.sql` | Q3 — Top-selling products by units and revenue |
| `07_customer_age_analysis.sql` | Q4 — Age distribution vs. purchase behavior |
| `08_top_spending_customers_analysis.sql` | Q5 — Top 10 spending customers |
| `09_country_performance_analysis.sql` | Q6 — Revenue & margin by country |
| `10_online_sales_analysis.sql` | Q8 — Online vs. physical channel & delivery time |
| `11_abc_analysis.sql` | Q9 — ABC (Pareto) analysis on products |
| `12_category_year_pivot_analysis.sql` | Q10 — Category revenue pivoted by year |

---

## Data Quality Note

During import, roughly 350 rows in `Products` (~14% of the table) had corrupted `Category` / `Subcategory` / `Brand` values. The cause: several genuine values contain commas (e.g. `"Printers, Scanners & Fax"`, `"Music, Movies and Audio Books"`), and the import tool's Text Qualifier setting was left blank, so it split on every comma instead of respecting quoted fields — shifting values across columns for any affected row.

**Diagnosis:** comparing `SELECT DISTINCT Category` (15 messy values) against the true category list parsed directly from the raw CSV (exactly 8 clean values) confirmed the scope.

**Fix:** re-imported the source file into a staging table with the correct Text Qualifier, then updated the live `Products` table from it. Full details are in the header comment of `05_profit_margin_analysis.sql`.

---

## Key Findings

### 1. Revenue & Profit Trend

Revenue grew strongly from 2016 through 2019 (+18% to +75% year-over-year), then declined 50% in 2020. Revenue and profit growth track closely together every year, meaning performance swings came from sales volume, not margin changes. *(2021 shows only Jan–Feb data — not a real annual decline.)*

![Revenue and Profit Trend](charts/01_revenue_profit_trend.png)

- **December** appears twice in the top 5 highest-revenue months (2018, 2019) — a holiday seasonality effect.
- **April** was the lowest-revenue month in every single year from 2016–2020 — a strong, consistent seasonal dip.

| Year | Revenue | Profit | YoY Revenue Growth | YoY Profit Growth |
|---|---|---|---|---|
| 2016 | $4,798,214 | $2,038,922 | — | — |
| 2017 | $5,659,328 | $2,639,583 | +17.9% | +29.5% |
| 2018 | $9,879,280 | $4,674,972 | +74.6% | +77.1% |
| 2019 | $14,663,602 | $7,211,354 | +48.4% | +54.3% |
| 2020 | $7,382,601 | $3,584,153 | -49.7% | -50.3% |
| 2021* | $852,421 | $421,596 | -88.5% | -88.2% |

*\*2021 covers Jan–Feb only.*

### 2. Profit Margin by Category & Brand

Higher sales volume doesn't guarantee the best margin. **Computers** is the largest category by both revenue ($16.1M) and unit volume (44,151), though its margin (50.1%) isn't the highest. **Music, Movies and Audio Books** has the best margin (61.0%) but operates at a much smaller scale. **TV and Video** is the weakest performer across all three metrics — lowest revenue ($2.75M), lowest units (11,236), lowest margin (13.0%) — a strong candidate for pricing or assortment review.

![Profit Margin by Category](charts/02_category_profit_margin.png)

| Category | Revenue | Profit | Margin | Units Sold |
|---|---|---|---|---|
| Music, Movies and Audio Books | $3,131,006 | $1,909,259 | 61.0% | 28,802 |
| Audio | $3,169,628 | $1,827,852 | 57.7% | 23,490 |
| Cell phones | $6,183,791 | $3,498,627 | 56.6% | 31,477 |
| Games and Toys | $724,829 | $396,669 | 54.7% | 22,591 |
| Cameras and camcorders | $5,285,457 | $2,685,090 | 50.8% | 17,609 |
| Computers | $16,077,227 | $8,053,080 | 50.1% | 44,151 |
| Home Appliances | $5,913,532 | $1,842,317 | 31.2% | 18,401 |
| TV and Video | $2,749,975 | $357,687 | 13.0% | 11,236 |

The same pattern holds for brands: **Contoso** and **Adventure Works** lead in revenue and units sold, but their margins (43.5% and 39.8%) are only mid-range. Smaller brands like **A. Datum** and **Southridge Video** run leaner, with margins around 59%. **Northwind Traders** has the weakest brand margin (20.7%).

### 3. Top-Selling Products

Ranking products separately by units sold and by revenue (using `RANK()`) reveals real disagreements between the two. Some products sell a high volume but rank far lower on revenue because they're cheap, and vice versa. For example, "Adventure Works Desktop PC1.60 ED160 Black" ranks **#3 by units** but only **#32 by revenue**, while "Adventure Works Desktop PC2.33 XD233 Brown" ranks **#17 by units** but **#3 by revenue**. A simple `TOP 10` on one metric alone would have missed this pattern entirely.

### 4. Customer Age vs. Purchase Behavior

Customer count increases steadily with age (1,488 customers under 25 vs. 4,354 above 60), which is why total revenue is highest for the 60+ group. But **average revenue per customer is nearly identical across every age group** (~$3,350–$3,550) — individual buying behavior does not vary meaningfully by age. Higher total revenue in older segments reflects a larger customer base, not higher per-customer value.

| Age Group | Total Revenue | Customer Count | Avg Revenue / Customer |
|---|---|---|---|
| Above 60 | $15,467,839 | 4,354 | $3,552.56 |
| 40-60 | $12,715,579 | 3,747 | $3,393.54 |
| 25-40 | $9,790,955 | 2,921 | $3,351.92 |
| Under 25 | $5,261,073 | 1,488 | $3,535.67 |

### 5. Top Spending Customers

The top 10 customers generated between $26.1K and $36.7K in total revenue, but their purchasing patterns vary considerably. **Michael Robertson** generated the highest revenue ($36,664) from 8 orders. **Jamie Gilbert** generated $26,681 from only 3 orders — implying a much higher average order value. **Gaspare Trevisan**, by contrast, generated $34,429 across 14 orders, a far more frequent purchasing pattern. High-value customers can reach similar totals through either a few large orders or many smaller ones, which may justify different retention strategies (VIP/consultative service vs. loyalty programs).

### 6. Performance by Country

The United States leads by a wide margin with **$18.4M** in revenue. The **Online** channel ranks second overall with **$8.9M**, outperforming every physical country except the US.

![Revenue by Country](charts/03_country_revenue.png)

Despite large differences in revenue scale, profit margins are relatively consistent across locations — ranging from 44.6% to 49.9% (a ~5.3-point spread). This is much narrower than the variation seen across product categories (13%–61%) or brands (20%–59%), suggesting geography is far less associated with profitability than product or brand mix is.

### 7. Online vs. Physical Channel & Delivery Time

`Delivery_Date` in the raw data is only ever populated for the Online store — physical-store customers take purchases home immediately, so the concept doesn't apply there. The **Online channel accounts for 21.2% of total orders and 20.7% of total revenue** — a nearly proportional share, meaning average order value is similar online and in-store.

Average Online delivery time improved from **7 days in 2016 to 3 days by Jan–Feb 2021**, with the largest gains happening between 2016 and 2018 — a substantial and sustained improvement in fulfillment speed, even during the 2020 revenue downturn.

### 8. ABC Analysis (Pareto Principle)

Ranking products by revenue and computing a running cumulative share shows the same imbalance the Pareto principle predicts, even if the exact split isn't a textbook 80/20:

![ABC Analysis](charts/04_abc_analysis.png)

| Category | Products | % of Catalog | Revenue | % of Revenue |
|---|---|---|---|---|
| A | 690 | 27.7% | $34,588,096 | ~80% |
| B | 671 | 26.9% | $6,480,643 | ~15% |
| C | 1,131 | 45.4% | $2,166,707 | ~5% |

**27.7% of products with recorded sales (690 of 2,492) drive ~80% of total revenue.** Category C — 1,131 products, 45.4% of the catalog — contributes only ~5% of revenue, making it a strong candidate for inventory and assortment review.

### 9. Category Revenue by Year (Pivot)

| Category | 2016 | 2017 | 2018 | 2019 | 2020 | 2021* |
|---|---|---|---|---|---|---|
| Audio | $339,348 | $472,048 | $798,012 | $1,064,198 | $452,726 | $43,297 |
| Cameras and camcorders | $777,236 | $540,046 | $1,012,231 | $1,890,375 | $956,674 | $108,895 |
| Cell phones | $429,497 | $653,411 | $1,372,746 | $2,311,958 | $1,256,726 | $159,454 |
| Computers | $1,232,521 | $1,934,042 | $3,764,933 | $5,877,193 | $2,917,130 | $351,409 |
| Games and Toys | $52,530 | $63,582 | $143,730 | $295,643 | $154,189 | $15,155 |
| Home Appliances | $1,000,330 | $1,208,893 | $1,527,495 | $1,497,165 | $632,695 | $46,954 |
| Music, Movies and Audio Books | $405,566 | $397,433 | $685,151 | $1,008,971 | $566,479 | $67,406 |
| TV and Video | $561,186 | $389,874 | $574,983 | $718,099 | $445,982 | $59,852 |

*\*2021 covers Jan–Feb only, so it isn't directly comparable to full-year totals.*

**Computers** shows strong revenue growth from 2016 to 2019 ($1.2M → $5.9M), before declining alongside the broader 2020 downturn. The 2019→2020 drop is visible across **every category**, confirming the overall revenue decline was broad-based rather than driven by a single struggling category.

---

## Conclusion: Strengths, Weaknesses & Recommendations

**Strengths**
- Strong, consistent revenue growth from 2016–2019 (+18% to +75% year-over-year), with profit growing in lockstep — margins held steady even as the business scaled.
- Profit margin is remarkably stable across every country (44.6%–49.9%), suggesting disciplined, consistent pricing regardless of market.
- The Online channel has steadily and continuously improved delivery time (7 days → 3 days), with no year of regression — a sign of real operational investment paying off.
- A small set of core categories (Computers, Cell phones) and a concentrated group of "A" products (27.7% of the catalog) reliably drive the large majority of revenue.

**Weaknesses**
- **TV and Video** underperforms on every metric simultaneously — lowest revenue, lowest unit volume, and lowest margin (13%) — suggesting a structural problem (pricing, sourcing cost, or weak demand) rather than a one-off dip.
- **Nearly half the product catalog (Category C, 45.4% of products) generates only ~5% of revenue** — this is a lot of inventory, shelf space, and operational overhead for very little return.
- Revenue is heavily concentrated in the **United States** (~42% of total revenue) — a geographic dependency that adds risk if that single market softens.
- The 2020 revenue decline (-49.7%) was **broad-based across every product category**, not isolated to one line — pointing to an external/market-wide cause rather than a product-specific issue.
- **Northwind Traders** is a clear underperforming brand (20.7% margin, well below every other brand).

**Recommendations**
1. Review pricing and supplier cost for the **TV and Video** category — its margin (13%) is far out of line with every other category and is worth investigating before deciding whether to reposition, discount clear, or drop underperforming SKUs.
2. Run a formal **inventory/assortment review on Category C products** — consolidating or discontinuing low-revenue SKUs could free up capital and operational focus with minimal revenue impact.
3. Prioritize **revenue diversification outside the US**, since the current concentration is a single-market risk.
4. Apply the same operational discipline behind the Online channel's delivery-time improvement to other weak spots identified here (e.g. TV and Video, Northwind Traders) — the pattern shows the business can execute sustained improvement when it invests in it.
5. Investigate the **external/market drivers behind the 2020 decline** specifically, since it affected every category at once — understanding whether it was demand-side, competitive, or macroeconomic will shape how to plan for a similar future shock.

---

## What I'd Explore Next

- **Cohort-based retention analysis** — group customers by the month of their first purchase and track how each cohort's repeat-purchase rate evolves over time, to see whether newer customers are more or less loyal than older ones.
- **A proper time-series forecast for 2021** — the 2021 data only covers Jan–Feb, so instead of just noting it's incomplete, a seasonal forecasting method (e.g. moving average or regression on prior years' seasonal pattern) could estimate what a full 2021 likely would have looked like. This would go beyond SQL into a statistical/Python tool.
