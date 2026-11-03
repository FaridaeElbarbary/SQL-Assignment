-----------------------------------------
    --1--
WITH CustomerTotalValue AS (

SELECT o.CustomerID,SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS TotalValue
FROM Orders o
join [Order Details] od on o.OrderID=od.OrderID
GROUP BY O.CustomerID
)

SELECT ctv.CustomerID,ctv.TotalValue,
    DENSE_RANK() OVER (
    ORDER BY TotalValue DESC) AS CustmerRank
FROM CustomerTotalValue ctv
ORDER BY CustmerRank

    --2--
WITH HighestPrice AS (

SELECT CategoryID,ProductName,UnitPrice,
DENSE_RANK()OVER( PARTITION BY CategoryID 
                  ORDER BY UnitPrice desc) as PriceRank
FROM Products
)
SELECT CategoryID,ProductName,UnitPrice
FROM HighestPrice
WHERE PriceRank=2

    --3--
WITH SOLDBY AS (

SELECT o.EmployeeID,SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS TotalValueSOLDBY
FROM Orders o
join [Order Details] od on o.OrderID=od.OrderID
GROUP by O.EmployeeID

)
SELECT EmployeeID,TotalValueSOLDBY,SUM(TotalValueSOLDBY) OVER(
        ORDER BY EmployeeID 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)AS RunningTotal
FROM SOLDBY

    --4--
WITH avgordervalue4emp AS (

SELECT EmployeeID,o.OrderID,SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS TotalValue
FROM Orders o
JOIN [Order Details] od on o.OrderID=od.OrderID
GROUP by O.EmployeeID,o.OrderID
),

avgordervalue as (
SELECT EmployeeID,avg(TotalValue) as avgordervalue
FROM avgordervalue4emp
GROUP BY EmployeeID
), 
overallavg as(
SELECT avg(avgordervalue) as overallavg
FROM avgordervalue
)

SELECT EmployeeID,avgordervalue
FROM avgordervalue aov
cross join overallavg
WHERE avgordervalue>overallavg
order by EmployeeID asc

    --5--
WITH MostOrder AS (

SELECT EmployeeID,
       COUNT(OrderID)AS OrderSold,
       YEAR(OrderDate) as Year
FROM Orders
WHERE EmployeeID=EmployeeID
GROUP by EmployeeID,YEAR(OrderDate)
), ranked as (
SELECT mo.EmployeeID
    ,mo.OrderSold,
    mo.Year,DENSE_RANK() OVER(PARTITION BY YEAR ORDER BY OrderSold desc) AS Ranked
FROM MostOrder mo
)
SELECT r.EmployeeID,r.OrderSold,r.Year,r.Ranked
FROM ranked r
WHERE Ranked =1

    --6--
WITH ProductPrice AS (

SELECT ProductID,ProductName,CategoryID,UnitPrice, DENSE_RANK() OVER(PARTITION BY CategoryID ORDER BY UnitPrice desc) as ranked
FROM Products
)
SELECT CategoryID,ProductID,ProductName,UnitPrice
FROM ProductPrice
WHERE ranked in (1,2,3)


    --7--
WITH ProductsSALES AS (

SELECT od.ProductID,p.ProductName,p.CategoryID,SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS TotalSalesAmount
FROM [Order Details] od
JOIN Products p 
    ON p.ProductID=od.ProductID
GROUP BY od.ProductID,p.ProductName,p.CategoryID
),
RANKED AS(
SELECT ProductID,ProductName,CategoryID,TotalSalesAmount,DENSE_RANK() OVER(PARTITION BY  CategoryID ORDER BY TotalSalesAmount) AS RANKED
FROM ProductsSALES
)
SELECT ProductID,ProductName,RANKED,CategoryID,TotalSalesAmount
FROM RANKED


    --8--
WITH HighestOrderValue  AS (

SELECT o.OrderID,o.EmployeeID,SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS TotalSalesAmount
FROM [Order Details] od
JOIN Orders o 
    ON o.OrderID=od.OrderID
group by o.OrderID ,o.EmployeeID
),RANKORDER AS (
SELECT EmployeeID,TotalSalesAmount,DENSE_RANK()OVER (PARTITION BY EmployeeID ORDER BY TotalSalesAmount DESC ) AS RANKED
FROM HighestOrderValue
)
SELECT EmployeeID,TotalSalesAmount,RANKED
FROM RANKORDER
WHERE RANKED=1

    --9--
WITH TotalSales AS (

SELECT od.OrderID,od.ProductID,p.CategoryID,c.CategoryName,SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS TotalSalesAmount
FROM [Order Details] od
JOIN Products p
    ON p.ProductID=od.ProductID
JOIN Categories c 
    ON c.CategoryID=p.CategoryID
group by od.OrderID,od.ProductID,p.CategoryID,c.CategoryName
)
SELECT CategoryID,CategoryName,TotalSalesAmount,SUM(TotalSalesAmount)OVER() as TotalSales,
    TotalSalesAmount*100 / SUM(TotalSalesAmount) OVER() AS SalePersantage
FROM TotalSales

    --10--
WITH CustmerAVG AS (

SELECT o.CustomerID,c.CompanyName,SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS SalesAmount
FROM [Order Details] od
JOIN Orders o
    ON o.OrderID=od.OrderID 
JOIN Customers c
    ON o.CustomerID=c.CustomerID
GROUP BY o.CustomerID,c.CompanyName
),AVGSalesAmount AS (
SELECT avg(SalesAmount) as AVGSalesAmount
FROM CustmerAVG
)
SELECT CustomerID,CompanyName,SalesAmount,ca.AVGSalesAmount
FROM CustmerAVG
cross join AVGSalesAmount ca
WHERE SalesAmount>ca.AVGSalesAmount

    --11--
WITH ProdectNEVERordered AS (
SELECT p.ProductID,p.ProductName,p.UnitPrice
FROM Products p
LEFT JOIN [Order Details] od 
    ON p.ProductID=od.ProductID
WHERE od.ProductID is NULL
)
SELECT *
FROM ProdectNEVERordered

    --12--
WITH TotalSales AS (

SELECT e.EmployeeID,CONCAT(e.FirstName,e.LastName) as FULLNAME,SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS SalesAmount,YEAR(o.OrderDate) as Years
FROM [Order Details] od
JOIN Orders o ON o.OrderID=od.OrderID
JOIN Employees e ON o.EmployeeID=e.EmployeeID
GROUP by e.EmployeeID,e.FirstName,e.LastName,YEAR(o.OrderDate) 
)
SELECT *
FROM TotalSales
order by Years asc