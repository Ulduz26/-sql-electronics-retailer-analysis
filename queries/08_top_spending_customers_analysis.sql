/* ============================================================
   Business Question 5: Top Spending Customers
   "Which 10 customers generated the most total revenue, and how
   many distinct orders did it take them to get there?"

   Uses COUNT(DISTINCT Order_Number) rather than COUNT(Order_Number)
   because Sales_Financials_USD has one row per line item, so a
   single order with multiple products would otherwise be counted
   multiple times.

    Finding: The top 10 customers generated between $26.1K and
   $36.7K in total revenue, but their purchasing patterns vary
   considerably. Michael Robertson generated the highest revenue
   ($36,664) from 8 orders, while Jamie Gilbert generated $26,681
   from only 3 orders, implying a much higher average order value.
   In contrast, Gaspare Trevisan generated $34,429 across 14 orders,
   showing a more frequent purchasing pattern. This suggests that
   high-value customers can reach similar total spending through
   either fewer, larger orders or more frequent, smaller orders,
   which may justify different retention strategies.
   ============================================================ */

SELECT TOP (10)
    sf.CustomerKey,
    c.Name,
    COUNT(DISTINCT sf.Order_Number) AS CountOrders,
    SUM(sf.Total_Revenue_USD) AS SumRevenue
FROM Sales_Financials_USD AS sf
INNER JOIN Customers AS c ON sf.CustomerKey = c.CustomerKey
GROUP BY sf.CustomerKey, c.Name
ORDER BY SumRevenue DESC;
