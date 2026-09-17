/* ============================================================
   Business Question 8: Online vs. Physical Channel & Delivery Time
   "What share of orders and revenue come from the Online store
   vs. physical stores, and how has Online delivery time changed
   over time?"

   Note: Delivery_Date is only populated for the Online store
   (StoreKey 0) - physical stores have no delivery data, since
   customers take purchases home immediately in-store.

    Finding: The Online channel accounts for 21.2% of total orders
    and 20.7% of total revenue, indicating that its share of
    revenue is almost proportional to its share of orders. Average
    recorded Online delivery time improved from 7 days in 2016 to
    3 days in Jan-Feb 2021, with the largest improvement occurring
    between 2016 and 2018. This suggests a substantial improvement
    in Online fulfillment speed over the period, although 2021 data
    covers only January and February.
   ============================================================ */


-- 8a. Share of orders: Online vs. physical stores
SELECT
    COUNT(DISTINCT Order_Number) AS TotalOrders,
    COUNT(DISTINCT CASE 
        WHEN StoreKey = 0 THEN Order_Number 
    END) AS OnlineOrders,
    (
        CAST(
            COUNT(DISTINCT CASE 
                WHEN StoreKey = 0 THEN Order_Number 
            END) AS DECIMAL(10,2)
        )
        / COUNT(DISTINCT Order_Number)
    ) * 100 AS OnlinePercent
FROM Sales;


-- 8b. Share of revenue: Online vs. physical stores
SELECT
    SUM(Total_Revenue_USD) AS TotalRevenue,
    SUM(CASE WHEN StoreKey = 0 THEN Total_Revenue_USD ELSE 0 END) AS OnlineRevenue,
    (SUM(CASE WHEN StoreKey = 0 THEN Total_Revenue_USD ELSE 0 END) / SUM(Total_Revenue_USD)) * 100 AS OnlineRevenuePercent
FROM Sales_Financials_USD;


-- 8c. Average delivery time for Online orders, by year
SELECT
    YEAR(Order_Date) AS OrderYear,
    AVG(DATEDIFF(DAY, Order_Date, Delivery_Date)) AS AvgDeliveryDays
FROM Sales
WHERE StoreKey = 0
GROUP BY YEAR(Order_Date)
ORDER BY OrderYear;



