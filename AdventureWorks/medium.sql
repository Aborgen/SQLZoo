-- AdventureWorks Medium Questions
-- https://zh.sqlzoo.net/wiki/AdventureWorks_medium_questions

-- 6)
-- A "Single Item Order" is a customer order where only one item is ordered.
-- Show the SalesOrderID and the UnitPrice for every Single Item Order.
SELECT SalesOrderID, UnitPrice
FROM SalesOrderDetail
WHERE SalesOrderID IN (
  SELECT SalesOrderID
  FROM SalesOrderDetail
  GROUP BY SalesOrderID
  HAVING COUNT(*) = 1
);

/*
+--------------+---------------------------+
| SalesOrderID |         UnitPrice         |
+--------------+---------------------------+
|        71776 |                     63.90 |
|        71867 |                    858.90 |
|        71917 |                      5.39 |
|        71938 |                   1020.59 |
+--------------+---------------------------+
*/

-- 7)
-- Where did the racing socks go? List the product name and the CompanyName
-- for all Customers who ordered ProductModel 'Racing Socks'.
Select p.Name AS ProductName, CompanyName
FROM SalesOrderDetail AS sod
JOIN Product AS p
ON sod.ProductID = p.ProductID
JOIN ProductModel AS pm
ON p.ProductModelID = pm.ProductModelID
JOIN SalesOrderHeader AS soh
ON sod.SalesOrderID = soh.SalesOrderID
JOIN Customer AS cust
ON soh.CustomerID = cust.CustomerID
WHERE pm.Name = 'Racing Socks';

/*
+-----------------+---------------------------------+
|   ProductName   |           CompanyName           |
+-----------------+---------------------------------+
| Racing Socks, L | Eastside Department Store       |
| Racing Socks, L | Riding Cycles                   |
| Racing Socks, M | Thrifty Parts and Sales         |
| Racing Socks, M | The Bicycle Accessories Company |
| Racing Socks, L | The Bicycle Accessories Company |
| Racing Socks, L | Essential Bike Works            |
| Racing Socks, M | Remarkable Bike Store           |
| Racing Socks, L | Remarkable Bike Store           |
| Racing Socks, L | Sports Products Store           |
| Racing Socks, M | Sports Products Store           |
+-----------------+---------------------------------+
*/

-- 8)
-- Show the product description for culture 'fr' for product with ProductID 736.
SELECT Description
FROM Product AS p
JOIN ProductModelProductDescription AS pmpd
ON p.ProductModelID = pmpd.ProductModelID
JOIN ProductDescription AS pd
ON pmpd.ProductDescriptionID = pd.ProductDescriptionID
WHERE ProductID = 736 AND Culture = 'fr';

/*
+-------------------------------------------------------------------------+
|                               Description                               |
+-------------------------------------------------------------------------+
| Le cadre LL en aluminium offre une conduite confortable, une excellente |
| absorption des bosses pour un très bon rapport qualité-prix.            |
+-------------------------------------------------------------------------+
*/

-- 9)
-- Use the SubTotal value in SaleOrderHeader to list orders from the largest to the smallest.
-- For each order show the CompanyName and the SubTotal and the total weight of the order.
SELECT CompanyName, SubTotal, Weight
FROM SalesOrderHeader AS soh
JOIN (
  SELECT soh2.SalesOrderID, SUM(Weight) AS Weight
  FROM SalesOrderHeader AS soh2
  JOIN SalesOrderDetail AS sod
  ON soh2.SalesOrderID = sod.SalesOrderID
  JOIN Product AS p
  ON sod.ProductID = p.ProductID
  GROUP BY soh2.SalesOrderID) AS Sales
ON soh.SalesOrderID = Sales.SalesOrderID
JOIN Customer AS c
ON soh.CustomerID = c.CustomerID
ORDER BY SubTotal DESC;

/*
+---------------------------------+-----------+-----------+
|           CompanyName           |  SubTotal |   Weight  |
+---------------------------------+-----------+-----------+
| Action Bicycle Specialists      | 108561.83 | 210102.90 |
| Metropolitan Bicycle Supply     |  98278.69 | 160097.40 |
| Bulk Discount Store             |  88812.86 |   6962.61 |
| Eastside Department Store       |  83858.43 |  96440.30 |
| Riding Cycles                   |  78029.69 | 103117.15 |
| Many Bikes Store                |  74058.81 | 236611.83 |
| Instruments and Parts Company   |  63980.99 | 241273.48 |
| Extreme Riding Supplies         |  57634.63 | 157114.51 |
| Trailblazing Sports   41622.05  |  92417.13 |           |
| Professional Sales and Service  |  39785.33 | 205195.49 |
| Nearby Cycle Shop               |  38418.69 | 204536.65 |
| Closest Bicycle Store           |  35775.21 | 141112.97 |
| Thrilling Bike Tours            |  13823.71 | 127056.40 |
| Paints and Solvents Company     |  12685.89 |  48075.50 |
| Remarkable Bike Store           |   6634.30 |  23730.33 |
| Engineered Bike Systems         |   3398.17 |  37420.66 |
| Sports Products Store           |   3324.28 |  25544.69 |
| Discount Tours                  |   2980.79 |  14599.56 |
| Sports Store                    |   2453.76 |  25997.05 |
| Coalition Bike Company          |   2415.67 |  27876.66 |
| Aerobic Exercise Company        |   2137.23 |   2656.02 |
| Tachometers and Accessories     |   2016.34 |  10591.33 |
| Thrifty Parts and Sales         |   1141.58 |   2131.88 |
| Vigorous Sports Store           |   1059.31 |   1043.26 |
| Good Toys                       |    880.35 |   2050.23 |
| Transport Bikes                 |    602.19 |  13301.08 |
| Channel Outlet                  |    550.39 |           |
| Futuristic Bikes                |    246.74 |           |
| The Bicycle Accessories Company |    106.54 |           |
| West Side Mart                  |     78.81 |    317.00 |
| Essential Bike Works            |     40.90 |           |
+---------------------------------+-----------+-----------+
*/

-- 10)
-- How many products in ProductCategory 'Cranksets' have been sold to an address in 'London'?
SELECT COUNT(*) AS ProductSold
FROM SalesOrderHeader AS soh
JOIN SalesOrderDetail AS sod
ON soh.SalesOrderID = sod.SalesOrderID
JOIN Product AS p
ON sod.ProductID = p.ProductID
JOIN ProductCategory AS pc
ON p.ProductCategoryID = pc.ProductCategoryID
JOIN (
  SELECT CustomerID, City
  FROM CustomerAddress AS ca
  JOIN Address AS a
  ON ca.AddressID = a.AddressID
  WHERE City = 'London') AS Addresses
ON soh.CustomerID = Addresses.CustomerID
WHERE pc.Name = 'Cranksets';

/*
+--------------+
| ProductSold  |
+--------------+
|            2 |
+--------------+
*/
