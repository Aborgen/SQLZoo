-- GuestHouse Medium Questions
-- https://zh.sqlzoo.net/wiki/Guest_House_Assessment_Medium

-- 6)
-- Ruth Cadbury. Show the total amount payable by guest Ruth Cadbury for her room bookings.
-- You should JOIN to the rate table using room_type_requested and occupants. 
SELECT SUM(nights*amount)
FROM booking AS b
JOIN guest AS g
ON b.guest_id = g.id
JOIN rate AS r
ON b.occupants = r.occupancy AND
   b.room_type_requested = r.room_type
WHERE first_name = 'Ruth' AND
      last_name  = 'Cadbury';
      
/*
+--------------------+
| SUM(nights*amount) |
+--------------------+
|             552.00 |
+--------------------+
*/

-- 7)
-- Including Extras. Calculate the total bill for booking 5346 including extras.
SELECT SUM(amount)
FROM (
  SELECT b.booking_id, r.amount + IFNULL(e.amount, 0) AS amount
  FROM booking AS b
  JOIN rate AS r
  ON b.occupants = r.occupancy AND b.room_type_requested = r.room_type
  LEFT JOIN extra AS e
  ON b.booking_id = e.booking_id
) AS Total
WHERE booking_id = 5346
GROUP BY booking_id;

/*
    SQLZOO             MINE
+-------------+   +-------------+  
| SUM(amount) |   | SUM(amount) |
+-------------+   +-------------+
|      118.56 |   |      72.00  | 
+-------------+   +-------------+
Not sure where the discrepancy lies. My query appears to be doing the right thing.
Note: It appears the extra table is completely empty (as of 2019-07-16)
*/

-- 8)
-- Edinburgh Residents. For every guest who has the word “Edinburgh” in their address
-- show the total number of nights booked. Be sure to include 0 for those guests who have
-- never had a booking. Show last name, first name, address and number of nights.
-- Order by last name then first name. 
SELECT last_name, first_name, address, SUM(IFNULL(nights, 0)) AS nights
FROM booking AS b
RIGHT JOIN guest AS g
ON b.guest_id = g.id
WHERE address LIKE 'Edinburgh%'
GROUP BY last_name, first_name, address
ORDER BY last_name, first_name;

/*
+-----------+------------+---------------------------+--------+
| last_name | first_name |          address          | nights |
+-----------+------------+---------------------------+--------+
| Brock     | Deidre     | Edinburgh North and Leith |      0 |
| Cherry    | Joanna     | Edinburgh South West      |      0 |
| Murray    | Ian        | Edinburgh South           |     13 |
| Sheppard  | Tommy      | Edinburgh East            |      0 |
| Thomson   | Michelle   | Edinburgh West            |      3 |
+-----------+------------+---------------------------+--------+
*/

-- 9)
-- How busy are we? For each day of the week beginning 2016-11-25 show the number of bookings
-- starting that day. Be sure to show all the days of the week in the correct order.
SELECT booking_date AS i, COUNT(booking_id) AS arrivals
FROM booking AS b
WHERE booking_date BETWEEN '2016-11-25 00:00:00' AND
                           '2016-12-01 23:59:59'
GROUP BY booking_date;

/*
+------------+----------+
|      i     | arrivals |
+------------+----------+
| 2016-11-25 |        7 |
| 2016-11-26 |        8 |
| 2016-11-27 |       12 |
| 2016-11-28 |        7 |
| 2016-11-29 |       13 |
| 2016-11-30 |        6 |
| 2016-12-01 |        7 |
+------------+----------+
Note: Not sure why booking_date has been aliased to i in SQLZoo's expected answer.
*/

-- 10)
-- How many guests? Show the number of guests in the hotel on the night of 2016-11-21.
-- Include all occupants who checked in that day but not those who checked out.
SELECT SUM(occupants)
FROM booking
WHERE booking_date < '2016-11-22 00:00:00' AND
booking_date + INTERVAL nights DAY > '2016-11-21 00:00:00';

/*
+----------------+
| SUM(occupants) |
+----------------+
|             39 |
+----------------+
*/
