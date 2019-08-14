-- Guest House Easy Questions
-- https://zh.sqlzoo.net/wiki/Guest_House_Assessment_Easy

-- 1)
-- Guest 1183. Give the booking_date and the number of nights for guest 1183.
SELECT booking_date, nights
FROM booking AS b
JOIN guest AS g
ON b.guest_id = g.id
WHERE g.id = 1183;

/*
+--------------+--------+
| booking_date | nights |
+--------------+--------+
| 2016-11-27   |      5 |
+--------------+--------+
*/

-- 2)
-- When do they get here? List the arrival time and the first and last names for all 
-- guests due to arrive on 2016-11-05, order the output by time of arrival.
SELECT arrival_time, first_name, last_name
FROM booking AS b
JOIN guest AS g
ON b.guest_id = g.id
WHERE booking_date BETWEEN '2016-11-05 00:00:00' AND
                           '2016-11-05 23:59:59'
ORDER BY arrival_time;

/*
+--------------+------------+-----------+
| arrival_time | first_name | last_name |
+--------------+------------+-----------+
| 14:00        | Lisa       | Nandy     |
| 15:00        | Jack       | Dromey    |
| 16:00        | Mr Andrew  | Tyrie     |
| 21:00        | James      | Heappey   |
| 22:00        | Justin     | Tomlinson |
+--------------+------------+-----------+
*/

-- 3)
-- Look up daily rates. Give the daily rate that should be paid for bookings with
-- ids 5152, 5165, 5154 and 5295. Include booking id, room type, number of occupants
-- and the amount.
SELECT DISTINCT booking_id, room_type_requested, occupants, amount
FROM booking As b
JOIN rate AS r
ON b.occupants = r.occupancy AND
   b.room_type_requested = r.room_type
WHERE b.booking_id IN (5152, 5165, 5154, 5295);

/*
+------------+---------------------+-----------+--------+
| booking_id | room_type_requested | occupants | amount |
+------------+---------------------+-----------+--------+
|       5152 | double              |         2 |  72.00 |
|       5154 | double              |         1 |  56.00 |
|       5295 | family              |         3 |  84.00 |
+------------+---------------------+-----------+--------+
*/

-- 4)
-- Who’s in 101? Find who is staying in room 101 on 2016-12-03,
-- include first name, last name and address. 
SELECT first_name, last_name, address
FROM booking AS b
JOIN guest AS g
ON b.guest_id = g.id
WHERE booking_date BETWEEN '2016-12-03 00:00:00' AND
                           '2016-12-03 23:59:59'
AND b.room_no = 101;

/*
+------------+-----------+-------------+
| first_name | last_name | address     |
+------------+-----------+-------------+
| Graham     | Evans     | Weaver Vale |
+------------+-----------+-------------+
*/

-- 5)
-- How many bookings, how many nights? For guests 1185 and 1270 show the number of
-- bookings made and the total number of nights.Your output should include the
-- guest id and the total number of bookings and the total number of nights.
SELECT guest_id, COUNT(nights), SUM(nights)
FROM booking AS b
JOIN guest AS g
ON b.guest_id = g.id
WHERE guest_id IN (1185, 1270)
GROUP BY guest_id;

/*
+----------+---------------+-------------+
| guest_id | COUNT(nights) | SUM(nights) |
+----------+---------------+-------------+
|     1185 |             3 |           8 |
|     1270 |             2 |           3 |
+----------+---------------+-------------+
*/
