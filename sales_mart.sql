-- Creating a Sales Mart Table for Looker Studio
CREATE OR REPLACE TABLE `incubyte.sales_mart` AS
WITH cleaned_data AS (
    SELECT 
        TransactionID,
        COALESCE(CustomerID, 0) AS CustomerID, -- Handling NULL values
        TransactionDate, 
        DATE(TransactionDate) AS order_date, -- Extracting date part
        TransactionAmount,
        COALESCE(PaymentMethod, 'Unknown') AS PaymentMethod,
        Quantity,
        DiscountPercent,
        City,
        COALESCE(StoreType, 'Unknown') AS StoreType,
        COALESCE(CustomerAge, (SELECT AVG(CustomerAge) FROM `incubyte.assessment_dataset` )) AS CustomerAge, -- Replacing NULLs with median
        COALESCE(CustomerGender, 'Unknown') AS CustomerGender,
        LoyaltyPoints,
        COALESCE(ProductName, 'Unknown') AS ProductName,
        COALESCE(Region, 'Unknown') AS Region,
        Returned, 
        FeedbackScore,
        ShippingCost,
        DeliveryTimeDays,
        IsPromotional,
        (TransactionAmount - (TransactionAmount * COALESCE(DiscountPercent, 0) / 100) - COALESCE(ShippingCost, 0)) AS NetRevenue 
    FROM `incubyte.assessment_dataset`
),
aggregated_data AS (
    SELECT 
        TransactionID,
        CustomerID,
        TransactionDate,
        order_date,
        TransactionAmount,
        NetRevenue,
        NetRevenue * 0.012 as NetRevenue_USD,
        PaymentMethod,
        Quantity,
        DiscountPercent,
        City,
        StoreType,
        CustomerAge,
        CustomerGender,
        LoyaltyPoints,
        ProductName,
        Region,
        Returned,
        FeedbackScore,
        ShippingCost,
        DeliveryTimeDays,
        IsPromotional,
        SUM(TransactionAmount) OVER (PARTITION BY CustomerID ORDER BY TransactionDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CustomerLifetimeValue, -- CLV Calculation
        COUNT(TransactionID) OVER (PARTITION BY CustomerID) AS CustomerTotalTransactions, -- Total Transactions per Customer
        AVG(TransactionAmount) OVER (PARTITION BY CustomerID) AS CustomerAvgTransactionValue, -- Average Spend per Customer
        RANK() OVER (PARTITION BY City ORDER BY TransactionAmount DESC) AS CitySalesRank, -- Ranking Sales by City
        MIN(order_date) OVER (PARTITION BY CustomerID) AS FirstOrderDate -- First Order Date Calculation
    FROM cleaned_data
)
SELECT * FROM aggregated_data;

