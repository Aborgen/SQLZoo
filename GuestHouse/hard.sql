-- Guest House Hard Questions
-- https://zh.sqlzoo.net/wiki/Guest_House_Assessment_Hard

-- 11)
-- Coincidence. Have two guests with the same surname ever stayed in the hotel on the evening?
-- Show the last name and both first names. Do not include duplicates.

-- Skip.

-- 12)
-- Check out per floor. The first digit of the room number indicates the floor – e.g. room 201 is
-- on the 2nd floor. For each day of the week beginning 2016-11-14 show how many rooms are being
-- vacated that day by floor number. Show all days in the correct order.
SELECT DISTINCT booking_date AS i,
(
  SELECT COUNT(*)
  FROM booking AS b_inner
  WHERE b_outer.booking_date = DATE_ADD(b_inner.booking_date, INTERVAL b_inner.nights DAY) AND 
        LEFT(room_no, 1) = 1
) AS 1st,
(
  SELECT COUNT(*)
  FROM booking AS b_inner
  WHERE b_outer.booking_date = DATE_ADD(b_inner.booking_date, INTERVAL b_inner.nights DAY) AND
        LEFT(room_no, 1) = 2
) AS 2nd,
(
  SELECT COUNT(*)
  FROM booking AS b_inner
  WHERE b_outer.booking_date = DATE_ADD(b_inner.booking_date, INTERVAL b_inner.nights DAY) AND
        LEFT(room_no, 1) = 3
) AS 3rd
FROM booking AS b_outer
WHERE booking_date BETWEEN '2016-11-14 00:00:00' AND
                           '2016-11-20 23:59:59'
ORDER BY i;

/*
+------------+-----+-----+-----+
|      i     | 1st | 2nd | 3rd |
+------------+-----+-----+-----+
| 2016-11-14 |   5 |   3 |   4 |
| 2016-11-15 |   6 |   4 |   1 |
| 2016-11-16 |   2 |   2 |   4 |
| 2016-11-17 |   5 |   3 |   6 |
| 2016-11-18 |   2 |   3 |   2 |
| 2016-11-19 |   5 |   5 |   1 |
| 2016-11-20 |   2 |   2 |   2 |
+------------+-----+-----+-----+
*/

-- 13)
-- Free rooms? List the rooms that are free on the day 25th Nov 2016.
SELECT DISTINCT room_no AS id
FROM booking
WHERE room_no NOT IN (
  SELECT room_no
  FROM booking
  WHERE '2016-11-25' BETWEEN booking_date AND
        DATE_ADD(booking_date, INTERVAL nights - 1 DAY)
);

/*
+-----+
| id  |
+-----+
| 207 |
| 210 |
| 304 |
+-----+
*/

-- 14)
-- Single room for three nights required. A customer wants a single room for three consecutive nights.
-- Find the first available date in December 2016.
SELECT room_no, DATE_ADD(booking_date, INTERVAL nights DAY) AS checking_out
FROM booking AS b_outer
JOIN room AS r
ON b_outer.room_no = r.id
WHERE r.room_type = 'single' AND
DATE_ADD(booking_date, INTERVAL nights DAY) BETWEEN '2016-12-01 00:00:00' AND
                                                    '2016-12-31 23:59:59' AND
NOT EXISTS (
  SELECT *
  FROM booking AS b_inner
  WHERE b_inner.room_no = b_outer.room_no AND
  (
    b_inner.booking_date >= DATE_ADD(b_outer.booking_date, INTERVAL b_outer.nights DAY) AND
    b_inner.booking_date < DATE_ADD(b_outer.booking_date, INTERVAL b_outer.nights + 3 DAY) -- We need to check up to three days in the future
	                                                                                       -- for potential bookings.
  )
)
ORDER BY checking_out
LIMIT 1;

/*
+-----+--------------+
| id  | checking_out |
+-----+--------------+
| 201 | 2016-12-11   |
+-----+--------------+
*/

-- 15)
-- Gross income by week. Money is collected from guests when they leave.
-- For each Thursday in November and December 2016, show the total amount of
-- money collected from the previous Friday to that day, inclusive.
SELECT DISTINCT booking_date AS Thursday, (
  SELECT IFNULL(SUM(rt.amount + e.amount), 0)
  FROM booking AS b_inner
  JOIN room AS rm
  ON b_inner.room_no = rm.id
  JOIN room_type AS rmt
  ON rm.room_type = rmt.id
  JOIN rate AS rt
  ON b_inner.occupants = rt.occupancy AND
     rmt.id = rt.room_type
  JOIN extra AS e
  ON b_inner.booking_id = e.booking_id
  WHERE
    DATE_ADD(b_inner.booking_date, INTERVAL b_inner.nights DAY) BETWEEN DATE_SUB(b_outer.booking_date, INTERVAL 6 DAY) AND
                                                                        b_outer.booking_date
) AS weekly_income
FROM booking AS b_outer
WHERE booking_date BETWEEN '2016-11-01 00:00:00' AND
                           '2016-12-31 23:59:59' AND
DAYOFWEEK(booking_date) = 5
ORDER BY Thursday;

/*
+------------+---------------+
|  Thursday  | weekly_income |
+------------+---------------+
| 2016-11-03 |          0.00 |
| 2016-11-10 |       3272.94 |
| 2016-11-17 |       3240.56 |
| 2016-11-24 |       2957.69 |
| 2016-12-01 |       2941.14 |
| 2016-12-08 |       2709.79 |
| 2016-12-15 |       2103.87 |
+------------+---------------+
*/