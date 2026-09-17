/* ============================================================
   Business Question 6: Sales Performance by Country
   "How does revenue, profit, and profit margin compare across
   the countries where stores operate?"

   Uses Stores.Country (the store's location) rather than
   Customers.Country (the customer's location), since this
   question is about operational/store performance, not customer
   demographics - these can differ and aren't interchangeable.

   Finding: The United States leads by a wide margin with $18.4M
   in revenue. The Online store/channel ranks second overall
   with $8.9M, outperforming every physical country except the
   United States. Despite large differences in revenue scale,
   profit margins are relatively consistent across locations,
   ranging from 44.6% to 49.9% (about a 5.3 percentage-point
   spread). This is much narrower than the variation observed
   across product categories (13%-61%) and brands (20%-59%),
   suggesting that geography is less strongly associated with
   profitability than product or brand mix in this dataset.
   ============================================================ */

SELECT
    s.Country,
    SUM(sf.Total_Profit_USD) AS TotalProfit,
    SUM(sf.Total_Revenue_USD) AS TotalRevenue,
    (SUM(sf.Total_Profit_USD) / SUM(sf.Total_Revenue_USD)) * 100 AS ProfitMargin
FROM Sales_Financials_USD AS sf
INNER JOIN Stores AS s ON sf.StoreKey = s.StoreKey
GROUP BY s.Country
ORDER BY TotalRevenue DESC;
