-- Congestion Hard Questions
-- https://zh.sqlzoo.net/wiki/Congestion_Hard

-- 1)
-- The first question is an instructional on how to create views on SQLZOO, as the default user does not have write permissions.

-- 2)
-- There are four types of permit. The most popular type means that this type has been issued the highest number of times.
-- Find out the most popular type, together with the total number of permits issued. 
WITH permits_by_type (permitType, count) AS
(
  SELECT chargeType, COUNT(*)
  FROM vehicle AS v
  JOIN permit AS p
  ON v.id = p.reg
  GROUP BY chargeType
)

SELECT permitType, count, (
  SELECT SUM(count) FROM permits_by_type
) AS totalPermits
FROM permits_by_type
ORDER BY count DESC
LIMIT 1;

/*
+------------+-------+--------------+
| permitType | count | totalPermits |
+------------+-------+--------------+
| Daily      |    27 |           47 |
+------------+-------+--------------+
*/

-- 3)
-- For each of the vehicles caught by camera 19 - show the registration, the earliest time at camera 19 
-- and the time and camera at which it left the zone. 
WITH vehicle_movements (vehicleId, cameraId, timestamp, zoneStatus) AS
(
  SELECT v.id, c.id AS cameraId, whn AS timestamp, perim
  FROM vehicle AS v
  JOIN image AS i
  ON v.id = i.reg
  JOIN camera AS c
  ON i.camera = c.id
)

SELECT DISTINCT vm_outer.vehicleId, (
  SELECT timestamp
  FROM vehicle_movements AS vm_inner
  WHERE vm_inner.vehicleId = vm_outer.vehicleId
  ORDER BY timestamp
  LIMIT 1 
) AS firstSpotted, leftZone, cameraOut
FROM vehicle_movements AS vm_outer
LEFT JOIN (
  SELECT vehicleId, timestamp AS leftZone, cameraId AS cameraOut
  FROM vehicle_movements
  WHERE zoneStatus = 'OUT'
) AS vehicles_exiting
ON vm_outer.vehicleId = vehicles_exiting.vehicleId
WHERE cameraId = 19
ORDER BY vehicleId, leftZone;

/*
+-----------+---------------------+---------------------+-----------+
| vehicleId |     firstSpotted    |       leftZone      | cameraOut |
+-----------+---------------------+---------------------+-----------+
| SO 02 CSP | 2007-02-25 06:57:31 | 2007-02-25 07:04:31 |        12 |
| SO 02 CSP | 2007-02-25 06:57:31 | 2007-02-25 07:45:11 |        10 |
| SO 02 CSP | 2007-02-25 06:57:31 | 2007-02-25 07:58:01 |        11 |
| SO 02 DSP | 2007-02-25 16:29:11 | 2007-02-25 18:54:30 |         9 |
| SO 02 JSP | 2007-02-25 17:07:00 |                     |           |
| SO 02 TSP | 2007-02-25 07:20:01 | 2007-02-26 05:13:30 |        10 |
+-----------+---------------------+---------------------+-----------+
*/

-- 4)
-- For all 19 cameras - show the position as IN, OUT or INTERNAL and the busiest hour for that camera. 
WITH cameraImages_per_hour(cameraId, images, hour, zoneStatus) AS
(
  SELECT c.id, COUNT(*), HOUR(i.whn), perim
  FROM camera AS c
  JOIN image AS i
  ON c.id = i.camera
  GROUP BY c.id, HOUR(i.whn), perim
)

SELECT cameraId, IFNULL(zoneStatus, 'INTERNAL') AS position, hour AS busiestHour
FROM cameraImages_per_hour AS cph_outer
WHERE images >= ALL (
  SELECT images
  FROM cameraImages_per_hour AS cph_inner
  WHERE cph_outer.cameraId = cph_inner.cameraId
);

/*
+----------+----------+-------------+
| cameraId | position | busiestHour |
+----------+----------+-------------+
|        1 | IN       |           6 |
|        2 | IN       |           7 |
|        3 | IN       |          17 |
|        5 | IN       |           7 |
|        8 | IN       |           7 |
|        9 | OUT      |          16 |
|       10 | OUT      |          18 |
|       11 | OUT      |          18 |
|       12 | OUT      |          18 |
|       15 | OUT      |          18 |
|       16 | OUT      |           7 |
|       17 | INTERNAL |           6 |
|       18 | INTERNAL |           7 |
|       18 | INTERNAL |          16 |
        19 | INTERNAL |           7 |
+----------+----------+-------------+
*/

-- 5)
-- Anomalous daily permits. Daily permits should not be issued for non-charging days.
-- Find a way to represent charging days. Identify the anomalous daily permits.

-- I interpret this question as asking "a vehicle may have at most one permit active at a time. Find any overlaps."
-- If a vehicle has a weekly permit starting at '2007-01-01' and a daily permit starting at '2007-01-03', that would be an overlap,
-- as the vehicle has both a weekly and a daily permit active on '2007-01-03'.
WITH legal_vehicles (vehicleId, chargeType, beginningDate) AS
(
  SELECT v.id, chargeType, sDate
  FROM vehicle AS v
  JOIN permit AS p
  ON v.id = p.reg
), 
daily_permits AS
(
  SELECT vehicleId, beginningDate AS dailyDate
  FROM legal_vehicles
  WHERE chargeType = 'Daily'
)

SELECT dp.vehicleId, dailyDate
FROM legal_vehicles AS lv
JOIN daily_permits AS dp
ON lv.vehicleId = dp.vehicleId
WHERE (
  dailyDate >= beginningDate AND
  dailyDate < DATE_ADD(beginningDate, INTERVAL 1 WEEK)
) AND chargeType = 'Weekly'
UNION
SELECT dp.vehicleId, dailyDate
FROM legal_vehicles AS lv
JOIN daily_permits AS dp
ON lv.vehicleId = dp.vehicleId
WHERE (
  dailyDate >= beginningDate AND
  dailyDate < DATE_ADD(beginningDate, INTERVAL 1 Month)
) AND chargeType = 'Monthly'
UNION
SELECT dp.vehicleId, dailyDate
FROM legal_vehicles AS lv
JOIN daily_permits AS dp
ON lv.vehicleId = dp.vehicleId
WHERE (
  dailyDate >= beginningDate AND
  dailyDate < DATE_ADD(beginningDate, INTERVAL 1 Year)
) AND chargeType = 'Annual';

-- 6)
-- Issuing fines: Vehicles using the zone during the charge period, on charging days must be issued with
-- fine notices unless they have a permit covering that day. List the name and address of such culprits,
-- give the camera and the date and time of the first offence.

-- The terms 'charge period' and 'charging days' need more clarification.
