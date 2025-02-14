-- 1. Total Sales by Region
SELECT Region, SUM(TransactionAmount) AS TotalSales
FROM `incubyte.sales_mart`
GROUP BY Region
ORDER BY TotalSales DESC;

-- 2. Total Sales by Store Type
SELECT StoreType, SUM(TransactionAmount) AS TotalSales
FROM `incubyte.sales_mart`
GROUP BY StoreType;

-- 3. Return Rate Analysis
SELECT Returned, COUNT(TransactionID) AS TotalReturns,
       (COUNT(TransactionID) * 100.0 / (SELECT COUNT(*) FROM sales_data)) AS ReturnPercentage
FROM `incubyte.sales_mart`
GROUP BY Returned;

-- 4. Average Discount Given per Region
SELECT Region, AVG(DiscountPercent) AS AvgDiscount
FROM `incubyte.sales_mart`
GROUP BY Region;

-- 5. Customer Age Impact on Returns
SELECT CustomerAge, COUNT(TransactionID) AS TotalTransactions,
       SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) AS ReturnedOrders,
       (SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(TransactionID)) AS ReturnRate
FROM `incubyte.sales_mart`
GROUP BY CustomerAge
ORDER BY CustomerAge;

-- 6. Finding Customers Who Have Made Repeat Purchases Using Self-Join
SELECT a.CustomerID, COUNT(a.TransactionID) AS RepeatPurchases
FROM `incubyte.sales_mart` a
JOIN `incubyte.sales_mart` b
ON a.CustomerID = b.CustomerID AND a.TransactionID <> b.TransactionID
GROUP BY a.CustomerID
HAVING COUNT(a.TransactionID) > 1;

-- 7. Identifying Transactions with the Same Amount but Different Customers
SELECT a.TransactionID, a.CustomerID AS Customer1, b.CustomerID AS Customer2, a.TransactionAmount
FROM `incubyte.sales_mart` a
JOIN `incubyte.sales_mart` b
ON a.TransactionAmount = b.TransactionAmount AND a.TransactionID <> b.TransactionID
ORDER BY a.TransactionAmount DESC;

-- 8. Customers Who Purchased the Same Product More Than Once
SELECT a.CustomerID, a.ProductName, COUNT(a.TransactionID) AS PurchaseCount
FROM `incubyte.sales_mart` a
JOIN `incubyte.sales_mart` b
ON a.CustomerID = b.CustomerID AND a.ProductName = b.ProductName AND a.TransactionID <> b.TransactionID
GROUP BY a.CustomerID, a.ProductName
HAVING COUNT(a.TransactionID) > 1;

-- 9. Identifying Customers Who Switched Payment Methods
SELECT a.CustomerID, a.PaymentMethod AS FirstPaymentMethod, b.PaymentMethod AS SecondPaymentMethod
FROM `incubyte.sales_mart` a
JOIN `incubyte.sales_mart` b
ON a.CustomerID = b.CustomerID AND a.TransactionID <> b.TransactionID AND a.PaymentMethod <> b.PaymentMethod
ORDER BY a.CustomerID;
