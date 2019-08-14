-- Neeps Medium Questions
-- https://zh.sqlzoo.net/wiki/Neeps_medium_questions

-- 6)
-- Show the 'size' of each of the co72010 events.
-- Size is the total number of students attending each event.
SELECT e.id AS eventid, COUNT(DISTINCT a.student) AS students
FROM attends AS a
JOIN event AS e
ON a.event = e.id
WHERE modle = 'co72010'
GROUP BY eventid;

/*
+-------------+----------+
|   eventid   | students |
+-------------+----------+
| co72013.L01 |        4 |
| co72013.L02 |        2 |
| co72013.T01 |        2 |
| co72013.T02 |        2 |
| co72013.T03 |        2 |
| co72013.T04 |        1 |
| co72013.T05 |        1 |
| co72013.T06 |        1 |
+-------------+----------+
*/

-- 7)
-- For each post-graduate module, show the size of the teaching team.
-- (post graduate modules start with the code co7).
SELECT m.id AS module, COUNT(DISTINCT t.staff) AS teachers
FROM modle AS m
JOIN event AS e
ON m.id = e.modle
JOIN teaches AS t
ON e.id = t.event
WHERE m.id LIKE 'co7%'
GROUP BY module;

/*
+---------+----------+
|  module | teachers |
+---------+----------+
| co72002 |        1 |
| co72003 |        2 |
| co72004 |        1 |
| co72005 |        2 |
| co72006 |        1 |
| co72010 |        2 |
| co72011 |        2 |
| co72012 |        1 |
| co72016 |        2 |
| co72017 |        1 |
| co72018 |        1 |
| co72021 |        1 |
| co72026 |        2 |
| co72033 |        1 |
+---------+----------+
*/

-- 8)
-- Give the full name of those modules which include
-- events taught for fewer than 10 weeks.
SELECT DISTINCT name AS module
FROM occurs AS o
JOIN event AS e
ON o.event = e.id
JOIN modle AS m
ON e.modle = m.id
GROUP BY e.id, name
HAVING COUNT(week) < 10;

/*
+--------------------------------+
|             module             |
+--------------------------------+
| Languages and Algorithms       |
| Project                        |
| Interactivity and the Internet |
| Internet Multimedia            |
+--------------------------------+
*/

-- 9)
-- Identify those events which start at the same time as one of the co72010 lectures.
SELECT id AS eventid
FROM event AS e
WHERE EXISTS (
  SELECT *
  FROM event AS e2
  WHERE modle = 'co72010' AND
        e2.tod = e.tod    AND
        e2.dow = e.dow
) AND
modle <> 'co72010';

/*
+----------------+
|     eventid    |
+----------------+
| co12004.T04    |
| co12004.T05    |
| co12005.T01    |
| co12005.T04    |
| co12006.L03    |
| co12008.L01    |
| co12012.T01    |
| co22005.T02    |
| co22005.T04    |
| co22005.T07    |
| co22005.T08    |
| co22006.L02    |
| co22008.T03    |
| co22008.T04    |
| co22009.T02    |
| co32011.T03    |
| co32014.T01    |
| co32016.L01    |
| co32018.L01    |
| co32021.L01    |
| co42001.L01    |
| co42010.T01    |
| co42015.T01    |
| co72006.L01    |
| co72016.T01    |
| co72018.T01    |
| coh2451.T01    |
| coh8412555.L01 |
| coh8412555.T02 |
| coh8412585.T03 |
| coh8412605.L01 |
| coh8412605.T01 |
| coh8412615.T03 |
| coh8412615.T05 |
+----------------+
*/

-- 10)
-- How many members of staff have contact time which is greater than the average?
SELECT name AS teacher, SUM(duration) AS contactTime
FROM staff AS s
JOIN teaches AS t
ON s.id = t.staff
JOIN event AS e
ON t.event = e.id
GROUP BY name
HAVING contactTime > (
  SELECT SUM(duration) / (
    SELECT COUNT(*)
    FROM staff
  )
  FROM event
)
ORDER BY contactTime DESC;

/*
+-----------------------+-------------+
|        teacher        | contactTime |
+-----------------------+-------------+
| Soutar, Alastair      |          35 |
| Turner, Susan         |          18 |
| Kemmer, Rob           |          16 |
| Chisholm, Ken         |          15 |
| Cumming, Andrew       |          14 |
| Bain, Dr Bob          |          14 |
| Macaulay, Catriona    |          14 |
| Smith, Ian            |          13 |
| Rutter, Malcolm       |          13 |
| Barclay, Ken          |          13 |
| Lui, Xiaodong         |          13 |
| Munoz, Dr Jose        |          11 |
| Greig, Frank          |          10 |
| Lawson, Shaun         |           9 |
| Mathieson, Stuart     |           9 |
| Jackson, Jim          |           9 |
| Smyth, Michael        |           9 |
| Scott, Graham         |           8 |
| Savage, Dr John       |           8 |
| Hastie, Colin         |           8 |
| McEwan, Tom           |           7 |
| Owens, Dr John        |           7 |
| z TBA7                |           7 |
| Rankin, Bob           |           6 |
| Kerridge, Prof Jon    |           6 |
| Turner, Phil          |           6 |
| Cowan, Bruce          |           6 |
| Morss, Dr Les         |           6 |
| Armitage, Dr Alistair |           6 |
| Murray, Jim           |           6 |
| Middleton, Steve      |           6 |
| Dougal, Colin         |           5 |
| Musson, Tim           |           5 |
| Peng, Taoxin          |           5 |
| Lawson, Alistair      |           5 |
+-----------------------+-------------+
*/
