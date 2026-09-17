/* ============================================================
   Business Question 2: Profit Margin by Category and Brand
   "Which product categories and brands have the highest and
   lowest profit margin (%), and how does that compare to their
   absolute revenue and unit volume?"
   ============================================================ */

/* ------------------------------------------------------------
   Data fix applied before this analysis:
   Products.csv was originally imported with no Text Qualifier,
   so commas inside fields (e.g. "Printers, Scanners & Fax") split
   into extra columns, shifting Brand/Category/Subcategory values
   for ~350 rows (garbage values like Category = '02,TV and Video',
   Brand = 'Scanner'). Fixed by re-importing into a staging table
   with Text Qualifier = ", then updating the live Products table
   from it. The 9 rows whose own Product_Name contains a comma
   (e.g. "Proseware ... Printer, Scanner, Copier") needed their
   Brand fixed manually afterward, since the staging fix only
   covered Category/Subcategory/Product_Name/Keys:
     UPDATE Products SET Brand = 'Proseware'
       WHERE ProductKey IN (656,660,685,689,714,718,733,737);
     UPDATE Products SET Brand = 'Tailspin Toys' WHERE ProductKey = 1826;
   ------------------------------------------------------------ */
CREATE TABLE Products_Staging (
    ProductKey VARCHAR(100),
    Product_Name VARCHAR(100),
    Brand VARCHAR(100),
    Color VARCHAR(100),
    Unit_Cost_USD VARCHAR(100),
    Unit_Price_USD VARCHAR(100),
    SubcategoryKey VARCHAR(100),
    Subcategory VARCHAR(100),
    CategoryKey VARCHAR(100),
    Category VARCHAR(100)
);
UPDATE t
SET t.Category = s.Category,
    t.SubcategoryKey = s.SubcategoryKey,
    t.Subcategory = s.Subcategory,
    t.CategoryKey = s.CategoryKey,
    t.Product_Name = s.Product_Name
FROM Products AS t
INNER JOIN Products_Staging AS s
    ON t.ProductKey = CAST(s.ProductKey AS INT);

-- Verification: should return exactly the 8 true categories
SELECT DISTINCT Category FROM Products;
-- Verification: should return 0 rows (no category outside the valid list)
SELECT DISTINCT Category
FROM Products
WHERE Category NOT IN (
    'Audio', 'Cameras and camcorders', 'Cell phones', 'Computers',
    'Games and Toys', 'Home Appliances', 'Music, Movies and Audio Books', 'TV and Video'
);

--  Clean up - staging table no longer needed
DROP TABLE Products_Staging;

UPDATE Products SET Brand = 'Proseware' WHERE ProductKey IN (656, 660, 685, 689, 714, 718, 733, 737);
UPDATE Products SET Brand = 'Tailspin Toys' WHERE ProductKey = 1826;

-- Verification: these 9 rows should now show correct brand names
SELECT ProductKey, Brand, Product_Name
FROM Products
WHERE ProductKey IN (656, 660, 685, 689, 714, 718, 733, 737, 1826);


-- --------------------------------------------------------------
-- 2a. Profit margin by Category
-- Finding: Computers is the largest category by both revenue
-- ($16.1M) and unit volume (44,151), although its profit margin
-- (50.1%) is not the highest. Music, Movies and Audio Books has
-- the highest margin (61.0%) but operates at a much smaller
-- sales scale. TV and Video performs weakest across all three
-- metrics, with the lowest revenue ($2.75M), unit volume (11,236),
-- and profit margin (13.0%), making it a candidate for pricing
-- or strategy review.   
-- --------------------------------------------------------------
SELECT
    Category,
    SUM(Total_Revenue_USD) AS TotalRevenue,
    SUM(Total_Profit_USD) AS TotalProfit,
    (SUM(Total_Profit_USD) / SUM(Total_Revenue_USD)) * 100 AS ProfitMargin,
    SUM(Quantity) AS TotalUnitsSold
FROM Sales_Financials_USD AS sf
INNER JOIN Products AS p ON sf.ProductKey = p.ProductKey
GROUP BY Category
ORDER BY ProfitMargin DESC;


-- --------------------------------------------------------------
-- 2b. Profit margin by Brand
--     Finding: Contoso and Adventure Works lead in revenue and
--     units sold, but their margins (43.5% and 39.8%) are only
--     mid-range. Smaller brands like A. Datum and Southridge
--     Video run leaner with higher margins (~59%) but far lower
--     volume. Northwind Traders has the weakest margin (20.7%).
-- --------------------------------------------------------------
SELECT
    Brand,
    SUM(Total_Revenue_USD) AS TotalRevenue,
    SUM(Total_Profit_USD) AS TotalProfit,
    (SUM(Total_Profit_USD) / SUM(Total_Revenue_USD)) * 100 AS ProfitMargin,
    SUM(Quantity) AS TotalUnitsSold
FROM Sales_Financials_USD AS sf
INNER JOIN Products AS p ON sf.ProductKey = p.ProductKey
GROUP BY Brand
ORDER BY ProfitMargin DESC;
