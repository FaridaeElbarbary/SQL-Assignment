SELECT *
FROM INFORMATION_SCHEMA.TABLES



SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='customers'

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='products'

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='orders'

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='shipments'

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='payments'

SELECT TOP 10 *
FROM customers
SELECT TOP 10 *
FROM orders
SELECT TOP 10 *
FROM products

SELECT TOP 10 *
FROM shipments
SELECT  *
FROM payments

--1.Total revenue by customer showing customer name and total revenue
CREATE VIEW TotalRevenue AS 

SELECT c.name,SUM(amount) AS TotalRevenue
FROM customers c
join orders o ON O.customer_id=c.customer_id
WHERE o.customer_id=o.customer_id

group by c.name

SELECT *
FROM TotalRevenue

--2.Customers with at least 3 orders showing customer name and order count
CREATE VIEW CustomersOrderCount AS 

SELECT c.name,COUNT(o.order_id) as OrderCount
FROM customers c 
join orders o ON O.customer_id=c.customer_id
group by c.name

HAVING COUNT(o.order_id)  >=3


SELECT *
FROM CustomersOrderCount

--3.Average order value per customer showing customer name and average amount
CREATE VIEW AverageOrderValue AS 

SELECT c.name,AVG(O.amount)AS OrderValue 
FROM customers c
join orders o ON O.customer_id=c.customer_id
GROUP BY  c.name

SELECT *
FROM AverageOrderValue

--4.Total revenue by product showing product name and totalrevenue
CREATE VIEW TotalRevenuebyProduct AS 

SELECT p.product_name,SUM(o.amount)as TotalRevenue
FROM products p
join orders o ON o.product_id=p.product_id
WHERE p.product_id=p.product_id
group by p.product_name

SELECT *
FROM TotalRevenuebyProduct


--5.Total quantity sold by product showing product name and total quantity sold
CREATE VIEW TotalQuantitySold  AS

SELECT p.product_name,SUM(O.quantity) AS TotalQuantity
FROM products p
JOIN orders o ON o.product_id=p.product_id 
GROUP BY p.product_name 

SELECT *
FROM TotalQuantitySold

--6.Number of orders per day showing order date and order count
CREATE VIEW OrdersPerDay AS 

SELECT order_date,COUNT(order_id)as Numberoforders
FROM orders
GROUP BY order_date

SELECT *
FROM OrdersPerDay

--7.Total sales per day showing order date and daily sales amount
CREATE VIEW TotalSalesPerDay AS

SELECT order_date,SUM(amount) AS TotalSales
FROM orders 
GROUP BY order_date

SELECT *
FROM TotalSalesPerDay

--8.Total payments by payment method showing payment method and total collected
CREATE VIEW TotalPaymentsbyPayment AS 

SELECT payment_method,SUM(payment_amount)AS TotalPayments
FROM payments 
GROUP BY payment_method

SELECT *
FROM TotalPaymentsbyPayment

--9.Total payments per day showing payment date and total payment amount
CREATE VIEW TotalPaymentsperDay AS 

SELECT payment_date,SUM(payment_amount)AS TotalPayments
FROM payments
GROUP BY payment_date

SELECT *
FROM TotalPaymentsperDay


--10.Shipment summary by carrier showing carrier name, shipment count, first shipping date, and last shipping date
CREATE VIEW ShipmentSummary AS 

SELECT carrier,COUNT(shipment_id) AS ShipmentCount,MIN(shipping_date) AS FirstShippingDate,MAX(shipping_date) AS LastShippingDate
FROM shipments
GROUP BY carrier


SELECT *
FROM ShipmentSummary

--Bounce Problems:
--1.Orders with shipping status: order ID, customer name, orderdate, shipped_status (shipped / not_shipped)
CREATE VIEW OrderswithShippingStatus AS 

SELECT o.order_id,c.name,o.order_date,
		CASE 
			WHEN S.shipment_id IS NOT NULL	THEN 'Shipped'
			else 'Not Shipped'
		END AS shipped_status
FROM orders o
JOIN customers c ON c.customer_id=o.customer_id
LEFT JOIN shipments s  ON s.order_id=o.order_id

SELECT *
FROM OrderswithShippingStatus

--2.Product price rank band: product name, price, price_bandbased on price (budget/standard/premium)
CREATE VIEW ProductPriceRank AS 

SELECT p.product_name,p.price,
		CASE 
			WHEN p.price <50 THEN 'Budget'
			WHEN p.price <300 THEN 'Standard'
			ELSE 'Premium'
		END AS Price_bandbased
FROM products p

SELECT *
FROM ProductPriceRank
