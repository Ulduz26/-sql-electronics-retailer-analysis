/* ============================================================
   Business Question 10: Category Revenue Pivot Table
   "Show total revenue by product category (rows) across each
   year (columns), like an Excel pivot table."

   Finding: Computers experienced strong revenue growth from 2016
  to 2019, increasing from $1.2M to $5.9M, before declining to
  $2.9M in 2020. The 2020-to-2021 decline is visible across most
  categories, although Music, Movies and Audio Books is an
  exception, with revenue increasing from $56K to $67K. The
  2021 figures are not directly comparable with full-year results
  because the source data only covers January and February 2021.
   ============================================================ */

SELECT Category, [2016], [2017], [2018], [2019], [2020], [2021]
FROM
(
    SELECT p.Category, YEAR(sf.Order_Date) AS Sales_Year,
           SUM(sf.Total_Revenue_USD) AS TotalRevenue
    FROM Products AS p
    INNER JOIN Sales_Financials_USD AS sf ON p.ProductKey = sf.ProductKey
    GROUP BY p.Category, YEAR(sf.Order_Date)
) AS SourceTable
PIVOT
(
    SUM(TotalRevenue)
    FOR Sales_Year IN ([2016], [2017], [2018], [2019], [2020], [2021])
) AS PivotTable;
