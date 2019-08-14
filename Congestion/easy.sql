-- Congestion Easy Questions
-- https://zh.sqlzoo.net/wiki/Congestion_Easy

-- 1)
-- Show the name and address of the keeper of vehicle SO 02 PSP.
SELECT name, address
FROM keeper AS k
JOIN vehicle AS v
ON k.id = v.keeper
WHERE v.id = 'SO 02 PSP';

/*
+----------------+-------------------+
|      name      |      address      |
+----------------+-------------------+
| Strenuous, Sam | Surjection Street |
+----------------+-------------------+
*/

-- 2)
-- Show the number of cameras that take images for incoming vehicles.
SELECT COUNT(*) AS cameras FROM camera;

/*
+---------+
| cameras |
+---------+
|      19 |
+---------+
*/

-- 3)
-- List the image details taken by Camera 10 before 26 Feb 2007. 
SELECT i.whn AS imageDate, v.id AS vehicleId, name AS owner, address
FROM camera AS c
JOIN image AS i
ON c.id = i.camera
JOIN vehicle AS v
ON i.reg = v.id
JOIN keeper AS k
ON v.keeper = k.id
WHERE c.id = 10 AND
      whn < '2007-02-26 00:00:00';

/*
+---------------------+-----------+-------------------+-----------------+
|      imageDate      | vehicleId |       owner       |     address     |
+---------------------+-----------+-------------------+-----------------+
| 2007-02-25 07:45:11 | SO 02 CSP | Ambiguous, Arthur | Absorption Ave. |
| 2007-02-25 18:08:40 | SO 02 ESP | Ambiguous, Arthur | Absorption Ave. |
+---------------------+-----------+-------------------+-----------------+
*/

-- 4)
-- List the number of images taken by each camera. Your answer should
-- show how many images have been taken by camera 1, camera 2 etc.
-- The list must NOT include the images taken by camera 15, 16, 17, 18 and 19.
SELECT c.id AS cameraId, COUNT(*) AS images
FROM camera AS c
JOIN image AS i
ON c.id = i.camera
WHERE c.id NOT BETWEEN 15 AND 19
GROUP BY cameraId;

/*
+----------+--------+
| cameraId | images |
+----------+--------+
|        1 |      1 |
|        2 |      1 |
|        3 |      5 |
|        5 |      1 |
|        8 |      2 |
|        9 |      8 |
|       10 |      4 |
|       11 |      3 |
|       12 |      4 |
+----------+--------+
*/

-- 5)
-- A number of vehicles have permits that start on 30th Jan 2007.
-- List the name and address for each keeper in alphabetical order without duplication. 
SELECT DISTINCT name, address
FROM keeper AS k
JOIN vehicle AS v
ON k.id = v.keeper
JOIN permit AS p
ON v.id = p.reg
WHERE p.sDate = '2007-01-30 00:00:00';
ORDER BY name;

/*
+-------------------+-----------------------+
|        name       |        address        |
+-------------------+-----------------------+
| Ambiguous, Arthur | Absorption Ave.       |
| Assiduous, Annie  | Attribution Alley     |
| Contiguous, Carol | Circumscription Close |
| Strenuous, Sam    | Surjection Street     |
+-------------------+-----------------------+
*/