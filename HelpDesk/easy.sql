-- Helpdesk Easy Questions
-- https://zh.sqlzoo.net/wiki/Helpdesk_Easy_Questions

-- 1)
-- There are three issues that include the words "index" and "Oracle".
-- Find the call_date for each of them
SELECT i.call_date, i.call_ref
FROM Issue AS i
WHERE i.Detail LIKE '%index%' AND i.Detail LIKE '%Oracle%';

/*
+---------------------+----------+
|      call_date      | call_ref |
+---------------------+----------+
| 2017-08-12 16:00:00 |     1308 |
| 2017-08-16 14:54:00 |     1697 |
| 2017-08-16 19:12:00 |     1731 |
+---------------------+----------+
*/

-- 2)
-- Samantha Hall made three calls on 2017-08-14.
-- Show the date and time for each
SELECT i.call_date, c.first_name, c.last_name
FROM Issue AS i
JOIN Caller AS c
ON i.Caller_id= c.Caller_id
WHERE c.first_name = 'Samantha' AND
      c.last_name  = 'Hall'     AND
      i.call_date  LIKE '2017-08-14%';

/*
+---------------------+------------+-----------+
|      call_date      | first_name | last_name |
+---------------------+------------+-----------+
| 2017-08-14 10:10:00 | Samantha   | Hall      |
| 2017-08-14 10:49:00 | Samantha   | Hall      |
| 2017-08-14 18:18:00 | Samantha   | Hall      |
+---------------------+------------+-----------+
*/

-- 3)
-- There are 500 calls in the system (roughly).
-- Write a query that shows the number that have each status.
SELECT i.status, COUNT(*) AS Volume
FROM Issue AS i
GROUP BY i.status;

/*
+--------+--------+
| status | Volume |
+--------+--------+
| Closed |    486 |
| Open   |     10 |
+--------+--------+
*/

-- 4)
-- Calls are not normally assigned to a manager but it does happen.
-- How many calls have been assigned to staff who are at Manager Level?
SELECT COUNT(*) AS mlcc
FROM Issue AS i
JOIN Staff AS s
ON i.Assigned_to = s.Staff_code
JOIN Level AS l
ON s.Level_code = l.Level_code
WHERE l.Manager = 'Y';

/*
+------+
| mlcc |
+------+
|   51 |
+------+
*/

-- 5)
-- Show the manager for each shift.
-- Your output should include the shift date and type; also the first and last name of the manager.
SELECT sft.Shift_date, sft.Shift_type, sff.first_name, sff.last_name
FROM Shift AS sft
JOIN Staff AS sff
ON sft.Manager = sff.Staff_code
ORDER BY Shift_date, Shift_type;

/*
+------------+------------+------------+-----------+
| Shift_date | Shift_type | first_name | last_name |
+------------+------------+------------+-----------+
| 2017-08-12 | Early      | Logan      | Butler    |
| 2017-08-12 | Late       | Ava        | Ellis     |
| 2017-08-13 | Early      | Ava        | Ellis     |
| 2017-08-13 | Late       | Ava        | Ellis     |
| 2017-08-14 | Early      | Logan      | Butler    |
| 2017-08-14 | Late       | Logan      | Butler    |
| 2017-08-15 | Early      | Logan      | Butler    |
| 2017-08-15 | Late       | Logan      | Butler    |
| 2017-08-16 | Early      | Logan      | Butler    |
| 2017-08-16 | Late       | Logan      | Butler    |
+------------+------------+------------+-----------+
*/
