-- AdventureWorks Hard Questions
-- https://zh.sqlzoo.net/wiki/AdventureWorks_hard_questions

-- 11)
-- For every customer with a 'Main Office' in Dallas show AddressLine1 of the 'Main Office'
-- and AddressLine1 of the 'Shipping' address - if there is no shipping address leave it blank.
-- Use one row per customer.
SELECT AddressLine1 AS MainOffice, (
  SELECT IFNULL(AddressLine1, '')
  FROM CustomerAddress AS ca2
  JOIN Address AS a2
  ON ca2.AddressID = a2.AddressID
  WHERE c.CustomerID = ca2.CustomerID AND
        City = 'Dallas'               AND
        AddressType = 'Shipping') AS Shipping
FROM Customer AS c
JOIN CustomerAddress AS ca
ON c.CustomerID = ca.CustomerID
JOIN Address AS a
ON ca.AddressId = a.AddressID
WHERE City = 'Dallas' AND
      AddressType = 'Main Office';
      
/*
+-------------------------------+------------------+
|          MainOffice           |     Shipping     |
+-------------------------------+------------------+
| P.O. Box 6256916              |                  |
| Po Box 8259024                | 9178 Jumping St. |
| 2500 North Stemmons Freeway   |                  |
| Po Box 8035996                |                  |
| 99828 Routh Street, Suite 825 |                  |
+-------------------------------+------------------+
*/

-- 12)
-- For each order show the SalesOrderID and SubTotal calculated three ways:
-- A) From the SalesOrderHeader
-- B) Sum of OrderQty*UnitPrice
-- C) Sum of OrderQty*ListPrice 
SELECT SalesOrderID, Subtotal,
(
  SELECT SUM(OrderQty * UnitPrice)
  FROM SalesOrderDetail AS sod
  WHERE soh.SalesOrderID = sod.SalesOrderID
) AS UnitPrice,
(
  SELECT SUM(OrderQty * ListPrice)
  FROM SalesOrderDetail AS sod
  JOIN Product AS p
  ON sod.ProductID = p.ProductID
  WHERE soh.SalesOrderID = sod.SalesOrderID
) AS ListPrice
FROM SalesOrderHeader AS soh;

/*
+--------------+----------+-----------+-----------+
| SalesOrderID | Subtotal | UnitPrice | ListPrice |
+--------------+----------+-----------+-----------+
| 71774        |   880.35 |    713.80 |   1189.66 |
| 71776        |    78.81 |     63.90 |   1 06.50 |
| 71780        | 38418.69 |  30600.81 |  56651.56 |
| 71782        | 39785.33 |  33319.68 |  55533.31 |
| 71783        | 83858.43 |  68141.99 | 121625.43 |
| 71784        |108561.83 |  90341.14 | 151932.58 |
| 71796        | 57634.63 |  47848.02 |  79746.71 |
| 71797        | 78029.69 |  65218.20 | 108986.40 |
| 71815        |  1141.58 |    926.91 |   1544.86 |
| 71816        |  3398.17 |   2847.37 |   4745.68 |
| 71831        |  2016.34 |   1712.91 |   2854.91 |
| 71832        | 35775.21 |  29187.03 |  50559.01 |
| 71845        | 41622.05 |  34208.70 |  57768.21 |
| 71846        |  2453.76 |   1929.58 |   3592.65 |
| 71856        |   602.19 |    500.30 |    833.84 |
| 71858        | 13823.71 |  11528.80 |  19214.74 |
| 71863        |  3324.28 |   2778.20 |   4633.78 |
| 71867        |  1059.31 |    858.90 |   1431.50 |
| 71885        |   550.39 |    524.64 |    874.44 |
| 71895        |   246.74 |    221.24 |    368.76 |
| 71897        | 12685.89 |  10585.01 |  17641.75 |
| 71898        | 63980.99 |  53248.57 |  88747.82 |
| 71899        |  2415.67 |   1901.38 |   3545.67 |
| 71902        | 74058.81 |  60526.52 | 106151.57 |
| 71915        |  2137.23 |   1732.86 |   2888.15 |
| 71917        |    40.90 |     37.73 |     62.93 |
| 71920        |  2980.79 |   2527.08 |   4211.88 |
| 71923        |   106.54 |     97.49 |    166.81 |
| 71935        |  6634.30 |   5535.13 |   9229.27 |
| 71936        | 98278.69 |  80142.85 | 138124.87 |
| 71938        | 88812.86 |   5102.95 |   8504.95 |
| 71946        |    38.95 |           |           |
+--------------+----------+-----------+-----------+
*/

-- 13)
-- Show the best selling item by value.
SELECT Name, SUM(OrderQty) AS NumberSold
FROM SalesOrderDetail AS sod
JOIN Product AS p
ON sod.ProductID = p.ProductID
GROUP BY p.ProductID, Name
ORDER BY NumberSold DESC
LIMIT 1;

-- 14)
-- Show how many orders are in the following ranges (in $): 
-- 0-99, 100-999, 1000-9999, 10000-inf
WITH Orders AS
(
  SELECT SubTotal
  FROM SalesOrderHeader
)

SELECT '0-99' AS PriceRange, COUNT(*) AS Orders, SUM(SubTotal) AS GrandTotal
FROM Orders
WHERE SubTotal BETWEEN 0 AND 99
GROUP BY 1
UNION ALL
SELECT '100-999', COUNT(*), SUM(SubTotal)
FROM Orders
WHERE SubTotal BETWEEN 100 AND 999
GROUP BY 1
UNION ALL
SELECT '1000-9999', COUNT(*), SUM(SubTotal)
FROM Orders
WHERE SubTotal BETWEEN 1000 AND 9999
GROUP BY 1
UNION ALL
SELECT '> 9999', COUNT(*), SUM(SubTotal)
FROM Orders
WHERE SubTotal >= 10000
GROUP BY 1;

/*
+-----------------+--------+------------+
| OrderPriceRange | Orders | GrandTotal |
+-----------------+--------+------------+
| 0-99            |      3 |	 158.66 |
| 100-999         |      5 |    2386.21 |
| 1000-9999       |     10 |   27561.43 |
| > 9999          |     14 |  835326.81 |
+-----------------+--------+------------+
*/

-- 15)
-- Identify the three most important cities. Show the break down of top level product category against city.
SELECT a.City, TopCategory, COUNT(*) AS Quantity
FROM SalesOrderHeader AS soh
JOIN SalesOrderDetail aS sod
ON soh.SalesOrderId = sod.SalesOrderId
JOIN Product AS p
ON sod.ProductId = p.ProductId
JOIN (
  SELECT DISTINCT pc1.ProductCategoryId, pc2.Name AS TopCategory
  FROM ProductCategory AS pc1
  JOIN ProductCategory AS pc2
  ON pc1.ParentProductCategoryId = pc2.ProductCategoryId
  WHERE pc2.ParentProductCategoryId IS NULL
) AS Categories
ON p.ProductCategoryId = Categories.ProductCategoryId
JOIN Address AS a
ON soh.BillToAddressId = a.AddressId
JOIN (
  SELECT City
  FROM SalesOrderHeader AS soh
  JOIN Address AS a
  ON soh.BillToAddressId = a.AddressId
  GROUP BY City
  ORDER BY SUM(SubTotal) DESC
  LIMIT 3
) AS a2
ON a.City = a2.City
GROUP BY City, TopCategory;

/*
+------------+-------------+----------+
|    City    | TopCategory | Quantity |
+------------+-------------+----------+
| London     | Accessories |        1 |
| London     | Bikes       |       13 |
| London     | Clothing    |        4 |
| London     | Components  |       29 |
| Union City | Accessories |        8 |
| Union City | Bikes       |       11 |
| Union City | Clothing    |       13 |
| Union City | Components  |       11 |
| Woolston   | Accessories |        8 |
| Woolston   | Bikes       |       16 |
| Woolston   | Clothing    |       11 |
| Woolston   | Components  |        8 |
+------------+-------------+----------+
*/
