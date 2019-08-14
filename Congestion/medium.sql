-- Congestion Medium Questions
-- https://zh.sqlzoo.net/wiki/Congestion_Medium

-- 1)
-- List the owners (name and address) of Vehicles caught by camera 1 or 18 without duplication.
SELECT DISTINCT name, address
FROM keeper AS k
JOIN vehicle AS v
ON k.id = v.keeper
JOIN image AS i
ON v.id = i.reg
JOIN camera AS c
ON i.camera = c.id
WHERE c.id IN (1, 18);

/*
+---------------------+-------------------+
|         name        |      address      |
+---------------------+-------------------+
| Ambiguous, Arthur   | Absorption Ave.   |
| Inconspicuous, Iain | Interception Rd.  |
| Strenuous, Sam      | Surjection Street |
+---------------------+-------------------+
*/

-- 2)
-- Show keepers (name and address) who have more than 5 vehicles.
SELECT name, address
FROM keeper AS k
JOIN vehicle AS v
ON k.id = v.keeper
GROUP BY 1, 2
HAVING COUNT(*) > 5;

/*
+----------------------------------------+
|         name        |      address     |
+----------------------------------------+
| Ambiguous, Arthur   | Absorption Ave.  |
| Inconspicuous, Iain | Interception Rd. |
+----------------------------------------+
*/

-- 3)
-- For each vehicle show the number of current permits (suppose today is the 1st of Feb 2007).
-- The list should include the vehicle.s registration and the number of permits. Current permits
-- can be determined based on charge types, e.g. for weekly permit you can use the date after
-- 24 Jan 2007 and before 02 Feb 2007.
WITH legal_vehicles (vehicleId, chargeType, beginningDate) AS
(
  SELECT v.id, chargeType, sDate
  FROM vehicle AS v
  JOIN permit AS p
  ON v.id = p.reg
)

SELECT vehicleId, COUNT(*) AS permits
FROM (
  SELECT vehicleId
  FROM legal_vehicles
  WHERE chargeType = 'Daily' AND
        beginningDate = '2007-02-01 00:00:00'
  UNION ALL
  SELECT vehicleId
  FROM legal_vehicles
  WHERE chargeType = 'Weekly' AND
        beginningDate BETWEEN '2007-01-25 00:00:00' AND
                              '2007-02-01 00:00:00'
  UNION ALL
  SELECT vehicleId
  FROM legal_vehicles
  WHERE chargeType = 'Monthly' AND
        beginningDate BETWEEN '2007-01-01 00:00:00' AND
		                      '2007-02-01 00:00:00'
  UNION ALL
  SELECT vehicleId
  FROM legal_vehicles
  WHERE chargeType = 'Annual' AND
        beginningDate BETWEEN '2006-02-01 00:00:00' AND
		                      '2007-02-01 00:00:00') AS active_permits
GROUP BY vehicleId;

/*
+-----------+---------+
| vehicleId | permits |
+-----------+---------+
| SO 02 DSP |       1 |
| SO 02 JSP |       1 |
| SO 02 KSP |       1 |
| SO 02 QSP |       1 |
| SO 02 RSP |       1 |
+-----------+---------+
*/

-- 4)
-- Obtain a list of every vehicle passing camera 10 on 25th Feb 2007.
-- Show the time, the registration and the name of the keeper if available. 
SELECT i.whn AS time, v.id AS vehicle, name AS owner
FROM vehicle AS v
JOIN image AS i
ON v.id = i.reg
JOIN camera AS c
ON i.camera = c.id
LEFT JOIN keeper AS k
ON v.keeper = k.id
WHERE c.id = 10 AND
      i.whn BETWEEN '2007-02-25 00:00:00' AND
                    '2007-02-25 23:59:59';
					
/*
+---------------------+-----------+-------------------+
|         time        |  vehicle  |       owner       |
+---------------------+-----------+-------------------+
| 2007-02-25 07:45:11 | SO 02 CSP | Ambiguous, Arthur |
| 2007-02-25 18:08:40 | SO 02 ESP | Ambiguous, Arthur |
| 2007-02-25 18:23:11 | SO 02 MUP |                   |
+---------------------+-----------+-------------------+
*/

-- 5)
-- List the keepers who have more than 4 vehicles and one of them must have more than 2 permits.
-- The list should include the names and the number of vehicles.
WITH permits_per_vehicle (vehicleId, owner) AS
(
  SELECT v.id, k.name
  FROM vehicle AS v
  JOIN keeper AS k
  ON v.keeper = k.id
  JOIN permit AS p
  ON v.id = p.reg
)

SELECT owner, COUNT(*) AS vehiclesOwned
FROM permits_per_vehicle
WHERE vehicleId = ANY (
  SELECT vehicleId         -- This subquery results in a list of vehicleIds that
  FROM permits_per_vehicle -- are associated with more than two permits.
  GROUP BY vehicleId
  HAVING COUNT(*) > 2
)
GROUP BY owner
HAVING COUNT(*) > 4;

/*
+---------------------+---------------+
|        owner        | vehiclesOwned |
+---------------------+---------------+
| Inconspicuous, Iain |             7 |
+---------------------+---------------+
*/
