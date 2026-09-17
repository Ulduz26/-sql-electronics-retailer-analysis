/* ============================================================
   Business Question 3: Top-Selling Products
   "Which products rank in the top 10 by units sold, by revenue,
   or both - and where do these two rankings disagree?"

   Uses a grouped CTE to first calculate total units and revenue
   per product, then applies window functions to rank these
   pre-aggregated results. This separates aggregation from ranking
   and keeps the query easier to read and validate.

   Finding: the two rankings frequently disagree - some products
   sell a high volume of units but rank much lower on revenue
   (they're cheaper), while others sell fewer units but rank much
   higher on revenue (they're pricier). E.g. "Adventure Works
   Desktop PC1.60 ED160 Black" ranks #3 by units but only #32 by
   revenue, while "Adventure Works Desktop PC2.33 XD233 Brown"
   ranks #17 by units but #3 by revenue. A simple TOP 10 by one
   metric alone would miss this pattern.
   ============================================================ */

WITH ProductTotals AS
(
    SELECT
        p.ProductKey,
        p.Product_Name,
        SUM(sf.Quantity) AS TotalUnits,
        SUM(sf.Total_Revenue_USD) AS TotalRevenue
    FROM Sales_Financials_USD AS sf
    INNER JOIN Products AS p ON sf.ProductKey = p.ProductKey
    GROUP BY p.ProductKey, p.Product_Name
),
ProductRanks AS
(
    SELECT
        ProductKey,
        Product_Name,
        TotalUnits,
        TotalRevenue,
        RANK() OVER (ORDER BY TotalUnits DESC) AS Rank_By_Units,
        RANK() OVER (ORDER BY TotalRevenue DESC) AS Rank_By_Revenue
    FROM ProductTotals
)
SELECT *
FROM ProductRanks
WHERE Rank_By_Revenue <= 10 OR Rank_By_Units <= 10
ORDER BY Rank_By_Revenue;
