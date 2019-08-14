-- Neeps Easy Questions
-- https://zh.sqlzoo.net/wiki/Neeps_easy_questions

-- 1)
-- Give the room id in which the event co42010.L01 takes place.
SELECT r.id AS roomid
FROM event AS e
JOIN room AS r
ON e.room = r.id
WHERE e.id = 'co42010.L01';

/*
+--------+
| roomid |
+--------+
| cr.132 |
+--------+
*/

-- 2)
-- For each event in module co72010 show the day, the time and the place.
SELECT e.dow AS day, e.tod AS time, e.room
FROM event AS e
WHERE modle = 'co72010';

/*
+-----------+-------+--------------+
|    day    |  time |     room     |
+-----------+-------+--------------+
| Wednesday | 14:00 | cr.SMH       |
| Tuesday   | 09:00 | cr.B8        |
| Wednesday | 09:00 | co.B7        |
| Tuesday   | 12:00 | co.LB42+LB46 |
| Tuesday   | 11:00 | co.G75+G76   |
| Wednesday | 16:00 | co.LB42+LB46 |
| Thursday  | 10:00 | co.LB42+LB46 |
| Wednesday | 13:00 | co.117+118   |
+-----------+-------+--------------+
*/

-- 3)
-- List the names of the staff who teach on module co72010.
SELECT DISTINCT s.name
FROM staff AS s
JOIN teaches AS t
ON s.id = t.staff
JOIN event AS e
ON t.event = e.id
WHERE e.modle = 'co72010';

/*
+-----------------+
|       name      |
+-----------------+
| Cumming, Andrew |
| Chisholm, Ken   |
+-----------------+
*/

-- 4)
-- Give a list of the staff and module number associated with events using
-- room cr.132 on Wednesday, include the time each event starts.
SELECT s.name AS teacher, e.modle AS module, e.tod AS start
FROM event AS e
JOIN teaches AS t
ON e.id = t.event
JOIN staff AS s
ON t.staff = s.id
WHERE e.dow = 'Wednesday' AND
      e.room = 'cr.132';
      
/*
+---------------+---------+-------+
|    teacher    |  module | start |
+---------------+---------+-------+
| Murray, Jim   | co22009 | 12:00 |
| Varey, Alison | co32021 | 09:00 |
+---------------+---------+-------+
*/

-- 5)
-- Give a list of the student groups which take modules
-- with the word 'Database' in the name.
SELECT DISTINCT s.name
FROM student AS s
JOIN attends AS a
ON s.id = a.student
JOIN event AS e
ON a.event = e.id
JOIN modle AS m
ON e.modle = m.id
WHERE UPPER(m.name) LIKE '%DATABASE%' AND
      s.name IS NOT NULL;

/*
+----------------------------------------+
|                  name                  |
+----------------------------------------+
| BSc4 Computing                         |
| BEng4 Network and Distributing Systems |
| PgD Information Systems                |
| PgD Information Systems a (HCI)        |
| PgD Information Systems b (DS)         |
| PgD Information Systems d (BT)         |
| PgD Information Systems e (OOP)        |
| PgD Information System pt. Tues        |
| PgD IT and e-Commerce                  |
| PgD IT and e-Commerce eve sem 3        |
| PgD Software Engineering               |
| PgD Software Technology                |
| PgD Software Technology pt. Tues       |
+----------------------------------------+
*/
