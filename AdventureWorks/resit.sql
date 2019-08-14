-- AdventureWorks Resit Questions
-- https://zh.sqlzoo.net/wiki/AdventureWorks_resit_questions

-- 1)
-- List the SalesOrderNumber for the customer 'Good Toys' 'Bike World'
SELECT CompanyName, COUNT(*) AS SalesOrderNumber
FROM SalesOrderHeader AS soh
JOIN Customer AS c
ON soh.CustomerId = c.CustomerId
WHERE CompanyName IN ('Good Toys', 'Bike World')
GROUP BY CompanyName;

/*
+-------------+------------------+
| CompanyName | SalesOrderNumber |
+-------------+------------------+
| Good Toys   |                1 |
+-------------+------------------+
*/

-- 2)
-- List the ProductName and the quantity of what was ordered by 'Futuristic Bikes'
SELECT p.Name AS ProductName, SUM(OrderQty) AS Quantity
FROM SalesOrderHeader AS soh
JOIN Customer AS c
ON soh.CustomerId = c.CustomerId
JOIN SalesOrderDetail AS sod
ON soh.SalesOrderId = sod.SalesOrderId
JOIN Product AS p
ON sod.ProductId = p.ProductId
WHERE CompanyName = 'Futuristic Bikes'
GROUP BY p.Name;

/*
+----------------------------+----------+
|         ProductName        | Quantity |
+----------------------------+----------+
| Classic Vest, S            |        3 |
| Long-Sleeve Logo Jersey, L |        2 |
| ML Mountain Seat/Saddle    |        2 |
+----------------------------+----------+
*/

-- 3)
-- List the name and addresses of companies containing the word 'Bike' (upper or lower case) and
-- companies containing 'cycle' (upper or lower case). Ensure that the 'bike's are listed before the 'cycles's.
SELECT CompanyName, AddressLine1 AS Address, City, StateProvince
FROM Customer AS c
JOIN CustomerAddress AS ca
ON c.CustomerId = ca.CustomerId
JOIN Address AS a
ON ca.AddressID = a.AddressId
WHERE UPPER(CompanyName) LIKE '%BIKE%'
UNION
SELECT CompanyName, AddressLine1, City, StateProvince
FROM Customer AS c
JOIN CustomerAddress AS ca
ON c.CustomerId = ca.CustomerId
JOIN Address AS a
ON ca.AddressID = a.AddressId
WHERE UPPER(CompanyName) LIKE '%CYCLE%'
ORDER BY CompanyName;

/*
+--------------------------+-----------------------------+----------------+---------------+
|        CompanyName       |           Address           |      City      | StateProvince |
+--------------------------+-----------------------------+----------------+---------------+
| A Bike Store             | 2251 Elliot Avenue          | Seattle        | Washington    |
| Advanced Bike Components | 12345 Sterling Avenue       | Irving         | Texas         |
| Associated Bikes         | 5420 West 22500 South       | Salt Lake City | Utah          |
| Sharp Bikes              | 52560 Free Street           | Toronto        | Ontario       |
| Bikes and Motorbikes     | 22580 Free Street           | Toronto        | Ontario       |
| Bike World               | 60025 Bollinger Canyon Road | San Ramon      | California    |
| Coalition Bike Company   | Corporate Office            | El Segundo     | California    |
| Two Bike Shops           | 35525-9th Street Sw         | Puyallup       | Washington    |
| Frugal Bike Shop         | 2575 West 2700 South        | Salt Lake City | Utah          |
| Gear-Shift Bikes Limited | 2512-4th Ave Sw             | Calgary        | Alberta       |
                                        .    .    .
                                        .    .    .
                                        .    .    .
+--------------------------+-----------------------------+----------------+---------------+

This table would be rather large, as you might imagine.
+--------------+-----------+
| NameFragment | Companies |
+--------------+-----------+
| BIKE         |       110 |
| CYCLE        |        74 |
+--------------+-----------+
*/

-- 4)
-- Show the total order value for each CountryRegion. List by value with the highest first.
SELECT CountyRegion, IFNULL(SUM(SubTotal + TaxAmt + Freight), 0) AS GrandTotal
FROM Address AS a
LEFT JOIN SalesOrderHeader AS soh
ON a.AddressId = soh.BillToAddressId 
GROUP BY CountyRegion
ORDER BY GrandTotal DESC;

/*
+----------------+------------+
|  CountyRegion  | GrandTotal |
+----------------+------------+
| United Kingdom |  572496.55 |
| United States  |  383807.02 |
| Canada         |       0.00 |
+----------------+------------+
*/

-- 5)
-- Find the best customer in each region.
-- Note: I'm sure I can come up with a better way of doing this...
SELECT DISTINCT CountyRegion,
(
  SELECT CONCAT(FirstName, ' ', LastName) AS Customer
  FROM Customer AS c
  JOIN CustomerAddress AS ca
  ON c.CustomerId = ca.CustomerId
  JOIN Address AS a_inner
  ON ca.AddressId = a_inner.AddressId
  WHERE a_outer.CountyRegion = a_inner.CountyRegion
  ORDER BY (
    SELECT SUM(SubTotal)
    FROM SalesOrderHeader AS soh
    WHERE soh.CustomerId = c.CustomerId
  ) DESC
  LIMIT 1
) AS Customer,
(
  SELECT (
    SELECT SUM(SubTotal)
    FROM SalesOrderHeader AS soh
    WHERE soh.CustomerId = c.CustomerId
  ) AS GrandTotal
  FROM Customer AS c
  JOIN CustomerAddress AS ca
  ON c.CustomerId = ca.CustomerId
  JOIN Address AS a_inner
  ON ca.AddressId = a_inner.AddressId
  WHERE a_outer.CountyRegion = a_inner.CountyRegion
  ORDER BY GrandTotal DESC
  LIMIT 1
) AS GrandTotal
FROM Address AS a_outer
ORDER BY CountyRegion;

/*
+----------------+-----------------+------------+
|  CountyRegion  |     Customer    | GrandTotal |
+----------------+-----------------+------------+
| Canada         | Shaun Beasley   |            |
| United Kingdom | Terry Eminhizer |  108561.83 |
| United States  | Kevin Liu       |   83858.43 |
+----------------+-----------------+------------+
*/