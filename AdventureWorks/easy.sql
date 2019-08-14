-- AdventureWorks Easy Questions
-- https://zh.sqlzoo.net/wiki/AdventureWorks_easy_questions

-- 1)
-- Show the first name and the email address of customer with CompanyName 'Bike World'
SELECT FirstName, EmailAddress
FROM Customer
WHERE CompanyName = 'Bike World';

/*
+-----------+----------------------------+
| FirstName |        EmailAddress        |
+-----------+----------------------------+
|   Kerim   | kerim0@adventure-works.com |
+-----------+----------------------------+
*/

-- 2)
-- Show the CompanyName for all customers with an address in City 'Dallas'.
SELECT DISTINCT CompanyName
FROM Customer as c
JOIN CustomerAddress AS ca
ON c.CustomerID = ca.CustomerID
JOIN Address AS a
ON ca.AddressID = a.AddressID
WHERE City = 'Dallas';

/*
+-------------------+
|    CompanyName    |
+-------------------+
| Town Industries   |
| Elite Bikes       |
| Third Bike Store  |
| Unsurpassed Bikes |
| Rental Bikes      |
+-------------------+
*/

-- 3)
-- How many items with ListPrice more than $1000 have been sold? 
SELECT SUM(OrderQty) As ProductsSold
FROM SalesOrderDetail AS sod
JOIN Product AS p
ON sod.ProductID = p.ProductID
WHERE p.ListPrice > 1000;

/*
+--------------+
| ProductsSold |
+--------------+
|          451 |
+--------------+
*/

-- 4)
-- Give the CompanyName of those customers with orders over $100000.
-- Include the subtotal plus tax plus freight.
SELECT CompanyName
FROM SalesOrderHeader AS soh
JOIN Customer AS c
ON soh.CustomerID = c.CustomerID
GROUP BY CompanyName
HAVING (SUM(SubTotal) +
        SUM(TaxAmt)   +
        SUM(Freight)) > 100000; -- 100,000

/*
+-----------------------------+
|         CompanyName         |
+-----------------------------+
| Action Bicycle Specialists  |
| Metropolitan Bicycle Supply |
+-----------------------------+
*/

-- 5)
-- Find the number of left racing socks ('Racing Socks, L') ordered by CompanyName 'Riding Cycles'
SELECT COUNT(*) AS SocksOrdered
FROM SalesOrderHeader AS soh
JOIN SalesOrderDetail AS sod
ON soh.SalesOrderID = sod.SalesOrderID
JOIN Product AS p
ON sod.ProductID = p.ProductID
JOIN Customer AS c
ON soh.CustomerID = c.CustomerID
WHERE c.CompanyName = 'Riding Cycles' AND
      p.Name ='Racing Socks, L';
	  
/*
+--------------+
| SocksOrdered |
+--------------+
|            1 |
+--------------+
*/
