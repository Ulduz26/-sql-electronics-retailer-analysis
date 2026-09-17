/* ============================================================
   Business Question 9: ABC Analysis on Products
   "Using the Pareto principle, which products contribute the
   most (A), moderate (B), and least (C) share of total revenue?"

   Products are ranked by revenue (highest first), a running
   cumulative revenue total is computed, converted to a
   cumulative percent of total revenue, and classified:
   A = cumulative % <= 80, B = 80-95%, C = above 95%.

   Finding: the exact split isn't the textbook 80/20, but the
   same imbalance holds - only 27.7% of products (690 of 2,492)
   account for 80% of total revenue (Category A). Category C
   (1,131 products, 45.4% of the catalog) contributes only 5% of
   revenue - nearly half the product catalog barely moves the
   needle, a candidate for inventory/assortment review.
   ============================================================ */

WITH ProductRevenue AS
(
    SELECT p.Product_Name, SUM(sf.Total_Revenue_USD) AS ProductRevenue
    FROM Products AS p
    INNER JOIN Sales_Financials_USD AS sf ON p.ProductKey = sf.ProductKey
    GROUP BY p.Product_Name
),
CumulativeRevenue AS
(
    SELECT Product_Name, ProductRevenue,
           SUM(ProductRevenue) OVER (ORDER BY ProductRevenue DESC) AS RunningTotal
    FROM ProductRevenue
),
CumulativePercentCTE AS
(
    SELECT Product_Name, ProductRevenue, RunningTotal,
           (RunningTotal / SUM(ProductRevenue) OVER ()) * 100 AS CumulativePercent
    FROM CumulativeRevenue
),
ABC_Classified AS
(
    SELECT Product_Name, ProductRevenue, RunningTotal, CumulativePercent,
           CASE
               WHEN CumulativePercent <= 80 THEN 'A'
               WHEN CumulativePercent > 80 AND CumulativePercent <= 95 THEN 'B'
               ELSE 'C'
           END AS ABC_Category
    FROM CumulativePercentCTE
)

-- Per-product detail with ABC label
SELECT * FROM ABC_Classified ORDER BY ProductRevenue DESC;


-- Summary: product count and revenue by ABC category
-- (CTEs only apply to the single statement right after them, so
-- the chain is repeated here for this second query)
WITH ProductRevenue AS
(
    SELECT p.Product_Name, SUM(sf.Total_Revenue_USD) AS ProductRevenue
    FROM Products AS p
    INNER JOIN Sales_Financials_USD AS sf ON p.ProductKey = sf.ProductKey
    GROUP BY p.Product_Name
),
CumulativeRevenue AS
(
    SELECT Product_Name, ProductRevenue,
           SUM(ProductRevenue) OVER (ORDER BY ProductRevenue DESC) AS RunningTotal
    FROM ProductRevenue
),
CumulativePercentCTE AS
(
    SELECT Product_Name, ProductRevenue, RunningTotal,
           (RunningTotal / SUM(ProductRevenue) OVER ()) * 100 AS CumulativePercent
    FROM CumulativeRevenue
),
ABC_Classified AS
(
    SELECT Product_Name, ProductRevenue, RunningTotal, CumulativePercent,
           CASE
               WHEN CumulativePercent <= 80 THEN 'A'
               WHEN CumulativePercent > 80 AND CumulativePercent <= 95 THEN 'B'
               ELSE 'C'
           END AS ABC_Category
    FROM CumulativePercentCTE
)
SELECT
    ABC_Category,
    COUNT(*) AS ProductCount,
    SUM(ProductRevenue) AS CategoryRevenue
FROM ABC_Classified
GROUP BY ABC_Category
ORDER BY ABC_Category;
