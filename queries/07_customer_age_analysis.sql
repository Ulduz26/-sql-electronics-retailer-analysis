/* ============================================================
   Business Question 4: Age Distribution vs. Purchase Behavior
   "What age groups do customers fall into, and how does that
   relate to total and average revenue per customer?"

   Age is calculated at the time of each order (DATEDIFF between
   Birthday and Order_Date), not relative to today, since sales
   data only spans 2016-2021.

   NOTE: Only customers with at least one purchase are included
   (INNER JOIN to Sales_Financials_USD). Of 15,266 total customers
   in the Customers table, only 11,887 (78%) have ever made a
   purchase - the remaining 3,379 are registered but have no
   sales record, and are naturally excluded here since this
   analysis is about purchase behavior.

   Finding: customer count increases steadily with age (1,488 in
   under-25 vs. 4,354 in above-60), which is why total revenue is
   highest for the above-60 group. But average revenue PER
   CUSTOMER is nearly identical across all age groups (~$3,350-
   $3,550) - individual buying behavior does not vary meaningfully
   by age. The higher total revenue for older age groups reflects
   a larger customer base, not higher per-customer value.
   ============================================================ */

WITH CustomerAgeSales AS
(
    SELECT
        c.CustomerKey,
        sf.Total_Revenue_USD,
        CASE
            WHEN DATEDIFF(YEAR, c.Birthday, sf.Order_Date) < 25 THEN 'under 25'
            WHEN DATEDIFF(YEAR, c.Birthday, sf.Order_Date) >= 25 AND DATEDIFF(YEAR, c.Birthday, sf.Order_Date) < 40 THEN '25-40'
            WHEN DATEDIFF(YEAR, c.Birthday, sf.Order_Date) >= 40 AND DATEDIFF(YEAR, c.Birthday, sf.Order_Date) < 60 THEN '40-60'
            WHEN DATEDIFF(YEAR, c.Birthday, sf.Order_Date) >= 60 THEN 'above 60'
        END AS AgeCategory
    FROM Customers AS c
    INNER JOIN Sales_Financials_USD AS sf ON c.CustomerKey = sf.CustomerKey
)
SELECT
    AgeCategory,
    SUM(Total_Revenue_USD) AS TotalRevenue,
    COUNT(DISTINCT CustomerKey) AS CustomerCount,
    (SUM(Total_Revenue_USD) / COUNT(DISTINCT CustomerKey)) AS AvgRevenuePerCustomer
FROM CustomerAgeSales
GROUP BY AgeCategory
ORDER BY TotalRevenue DESC;
