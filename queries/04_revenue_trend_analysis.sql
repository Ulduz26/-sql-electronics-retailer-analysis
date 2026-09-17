/* ============================================================
   Business Question 1: Monthly/Yearly Revenue & Profit Trend
   "How has total revenue and profit evolved over time, which
   months/years performed best and worst, and how does year-
   over-year growth compare between revenue and profit?"

   NOTE: 2021 data is incomplete (only Jan-Feb are present in
   the source data), so the sharp 2021 decline shown below is
   largely a data-completeness artifact, not a real business
   decline. This should be called out whenever these results
   are presented or visualized.
   ============================================================ */

-- --------------------------------------------------------------
-- 1a. Monthly revenue & profit trend across the full date range
-- --------------------------------------------------------------
SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    SUM(Total_Revenue_USD) AS TotalRevenue,
    SUM(Total_Profit_USD) AS TotalProfit
FROM Sales_Financials_USD
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Sales_Year, Sales_Month;


-- --------------------------------------------------------------
-- 1b. Top 5 highest-revenue months
--     Finding: December appears twice in the top 5 (2018, 2019),
--     suggesting a seasonal holiday-shopping effect.
-- --------------------------------------------------------------
SELECT TOP 5
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    SUM(Total_Revenue_USD) AS TotalRevenue,
    SUM(Total_Profit_USD) AS TotalProfit
FROM Sales_Financials_USD
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY TotalRevenue DESC;


-- --------------------------------------------------------------
-- 1c. Bottom 5 lowest-revenue months
--     Finding: April is the lowest-revenue month in every single
--     year from 2016-2020 - a strong, consistent seasonal dip.
-- --------------------------------------------------------------
SELECT TOP 5
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    SUM(Total_Revenue_USD) AS TotalRevenue,
    SUM(Total_Profit_USD) AS TotalProfit
FROM Sales_Financials_USD
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY TotalRevenue;


-- --------------------------------------------------------------
-- 1d. Year-over-year revenue and profit growth (%)
--     Uses LAG() to compare each year's totals against the
--     previous year.
--     Finding: revenue and profit growth move together closely
--     each year, meaning swings in performance come mainly from
--     changes in sales volume rather than changes in margin.
-- --------------------------------------------------------------
WITH YearlyTotals AS
(
    SELECT
        YEAR(Order_Date) AS Sales_Year,
        SUM(Total_Revenue_USD) AS TotalRevenue,
        SUM(Total_Profit_USD) AS TotalProfit
    FROM Sales_Financials_USD
    GROUP BY YEAR(Order_Date)
)
SELECT
    Sales_Year,
    LAG(TotalRevenue) OVER (ORDER BY Sales_Year) AS PreviousYearRevenue,
    TotalRevenue,
    ((TotalRevenue - LAG(TotalRevenue) OVER (ORDER BY Sales_Year))
        / LAG(TotalRevenue) OVER (ORDER BY Sales_Year) * 100) AS YoY_Revenue_Growth_Percent,
    LAG(TotalProfit) OVER (ORDER BY Sales_Year) AS PreviousYearProfit,
    TotalProfit,
    ((TotalProfit - LAG(TotalProfit) OVER (ORDER BY Sales_Year))
        / LAG(TotalProfit) OVER (ORDER BY Sales_Year) * 100) AS YoY_Profit_Growth_Percent
FROM YearlyTotals;
