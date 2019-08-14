-- Musicians Easy Questions
-- https://zh.sqlzoo.net/wiki/Musicians_easy_questions

-- 1)
-- Give the organiser's name of the concert in the Assembly Rooms after the first of Feb, 1997.
SELECT m_name AS organiser
FROM concert AS c
JOIN musician AS m
ON c.concert_orgniser = m.m_no
WHERE concert_venue = 'Assembly Rooms' AND
      con_date > '1997-02-01';
      
/*
+---------------+
|   organiser   |
+---------------+
| James Steeple |
+---------------+
*/

-- 2)
-- Find all the performers who played guitar or violin and were born in England.
SELECT m_name AS name
FROM performer AS perf
JOIN musician AS m
ON perf.perf_is = m.m_no
JOIN place AS plc
ON m.born_in = plc.place_no
WHERE plc.place_country = 'England' AND
      perf.instrument IN ('guitar', 'violin');

/*
+------------------+
|       name       |
+------------------+
| Harry Forte      |
| Davis Heavan     |
| Alan Fluff       |
| Theo Mengel      |
| James First      |
| Harriet Smithson |
+------------------+
*/

-- 3)
-- List the names of musicians who have conducted concerts in USA
-- together with the towns and dates of these concerts.
SELECT DISTINCT m_name AS conductor, place_town AS town, con_date AS date
FROM performance as pfmc
JOIN musician AS m
ON pfmc.conducted_by = m.m_no
JOIN concert AS c
ON pfmc.performed_in = c.concert_no
JOIN place AS plc
ON c.concert_in = plc.place_no
WHERE plc.place_country = 'USA';

/*
+---------------+----------+------------+
|   conductor   |   town   |    date    |
+---------------+----------+------------+
| James Steeple | New York | 1995-06-15 |
+---------------+----------+------------+
*/

-- 4)
-- How many concerts have featured at least one composition by Andy Jones?
-- List concert date, venue and the composition's title.
SELECT performances.date, performances.venue, performances.composition
FROM (
  SELECT cmpn.c_no AS compositionId, con_date AS date, concert_venue AS venue, c_title AS composition
  FROM performance AS pfmc
  JOIN concert AS cert
  ON pfmc.performed_in = cert.concert_no
  JOIN composition AS cmpn
  ON pfmc.performed = cmpn.c_no) AS performances
JOIN (
  SELECT cmpn_no AS id, m_name AS composer
  FROM has_composed AS hc
  JOIN composer AS cmpr
  ON hc.cmpr_no = cmpr.comp_no
  JOIN musician AS m
  ON cmpr.comp_is = m.m_no) AS compositions
ON performances.compositionId = compositions.id
WHERE compositions.composer = 'Andy Jones';

/*
+------------+--------------+----------------+
|    date    |     venue    |   composition  |
+------------+--------------+----------------+
| 1997-06-15 | Metropolitan | A Simple Piece |
+------------+--------------+----------------+
*/

-- 5)
-- list the different instruments played by the musicians and
-- avg number of musicians who play the instrument.
SELECT instrument, COUNT(*) / (
  SELECT COUNT(*) FROM performer
) * 100 AS average
FROM performer
GROUP BY instrument;

/*
+------------+---------+
| instrument | average |
+------------+---------+
| banjo      |  3.4483 |
| bass       | 10.3448 |
| cello      | 10.3448 |
| clarinet   |  3.4483 |
| cornet     |  3.4483 |
| drums      |  6.8966 |
| flute      |  6.8966 |
| guitar     |  6.8966 |
| horn       |  3.4483 |
| trombone   |  3.4483 |
| trumpet    |  3.4483 |
| viola      | 13.7931 |
| violin     | 24.1379 |
+------------+---------+
*/
