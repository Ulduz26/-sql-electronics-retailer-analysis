/* ============================================================
   Global Electronics Retailer - Sales Financials View
   Creates a reusable view joining Sales with Products to
   calculate revenue, cost, and profit per sales line, in USD.
   Includes key dimension columns (Line_Item, ProductKey,
   StoreKey, CustomerKey, Order_Date) so this view can be used
   directly for time-based, product-based, store-based, and
   customer-based analysis without needing to re-join Sales.

   IMPORTANT NOTE ON CURRENCY:
   Per the dataset's official Data_Dictionary.csv:
     - Products.Unit Price USD = "Product list price in USD"
     - Products.Unit Cost USD  = "Cost to produce the product in USD"
     - Sales.Currency Code     = "Currency used to process the order"
   Unit_Price_USD and Unit_Cost_USD are ALREADY denominated in USD
   regardless of which currency processed the transaction. No
   conversion using the Exchange_Rates table is needed to compute
   USD revenue/cost/profit - dividing by Exchange_Rates would
   incorrectly convert USD into a foreign-currency equivalent
   instead of keeping it in USD.
   The Exchange_Rates table is only needed if a separate analysis
   requires the local-currency equivalent of a sale (not used here).


   ============================================================ */

CREATE VIEW Sales_Financials_USD AS
SELECT
    s.Order_Number,
    s.Line_Item,
    s.ProductKey,
    s.CustomerKey,
    s.StoreKey,
    s.Order_Date,
    s.Quantity,
    p.Unit_Cost_USD,
    p.Unit_Price_USD,
    (s.Quantity * p.Unit_Price_USD) AS Total_Revenue_USD,
    (s.Quantity * p.Unit_Cost_USD) AS Total_Cost_USD,
    ((s.Quantity * p.Unit_Price_USD) - (s.Quantity * p.Unit_Cost_USD)) AS Total_Profit_USD
FROM Sales AS s
INNER JOIN Products AS p
    ON s.ProductKey = p.ProductKey;
GO

-- Quick sanity check after creating the view (should return 62884)
SELECT COUNT(*) FROM Sales_Financials_USD;
