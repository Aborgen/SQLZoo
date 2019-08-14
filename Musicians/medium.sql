-- Musicians Medium Questions
-- https://zh.sqlzoo.net/wiki/Musicians_medium_questions

-- 6)
-- List the names, dates of birth and the instrument played of living
-- musicians who play a instrument which Theo also plays.
WITH performers (name, DOB, instrument) AS
(
  SELECT m_name, born, instrument
  FROM performer AS perf
  JOIN musician AS m
  ON perf.perf_is = m.m_no
)

SELECT name, DOB, instrument
FROM performers
WHERE instrument IN (
  SELECT instrument
  FROM performers 
  WHERE name LIKE 'Theo%'
) AND name NOT LIKE 'Theo%'
ORDER BY name, DOB, instrument;

/*
+------------------+------------+------------+
|       name       |     DOB    | instrument |
+------------------+------------+------------+
| Alan Fluff       | 1935-01-15 | violin     |
| Harriet Smithson | 1909-05-09 | violin     |
| Harry Forte      | 1951-02-28 | drums      |
| Harry Forte      | 1951-02-28 | violin     |
| James First      | 1965-06-10 | violin     |
| Jeff Dawn        | 1945-12-12 | violin     |
| John Smith       | 1950-03-03 | violin     |
+------------------+------------+------------+
*/

-- 7)
-- List the name and the number of players for the band whose number of
-- players is greater than the average number of players in each band.
WITH members_per_band (bandName, memberCount) AS
(
  SELECT band_name, COUNT(player)
  FROM band AS b
  JOIN plays_in AS pi
  ON b.band_no = pi.band_id
  GROUP BY band_no, band_name
)

SELECT bandName, memberCount AS players
FROM members_per_band
WHERE memberCount > (
  SELECT AVG(memberCount)
  FROM members_per_band
);

/*
+----------+---------+
| bandName | players |
+----------+---------+
| ROP      |       7 |
| AASO     |       7 |
| Oh well  |       6 |
+----------+---------+
*/

-- 8)
-- List the names of musicians who both conduct and compose and live in Britain.
SELECT name
FROM (
  SELECT DISTINCT m_name AS name
  FROM musician AS m
  JOIN performance AS pfmc
  ON m.m_no = pfmc.conducted_by
  JOIN place AS plc
  ON m.living_in = plc.place_no
  WHERE place_country = 'England'
  UNION ALL
  SELECT DISTINCT m_name
  FROM musician AS m
  JOIN composer AS c
  ON m.m_no = c.comp_is
  JOIN place AS plc
  ON m.living_in = plc.place_no
  WHERE place_country = 'England'
) AS conductor_or_composer
GROUP BY name
HAVING COUNT(*) >= 2;

/*
+-------------+
|     name    |
+-------------+
| Phil Hot    |
| Rose Spring |
| Tony Smythe |
+-------------+
*/

-- 9)
-- Show the least commonly played instrument and the number of musicians who play it.
SELECT instrument, COUNT(*) AS players
FROM performer
GROUP BY instrument
HAVING COUNT(*) = 1;

/*
+------------+---------+
| instrument | players |
+------------+---------+
| banjo      |       1 |
| clarinet   |       1 |
| cornet     |       1 |
| horn       |       1 |
| trombone   |       1 |
| trumpet    |       1 |
+------------+---------+
*/

-- 10)
-- List the bands that have played music composed by Sue Little;
-- Give the titles of the composition in each case.
SELECT band_name AS band, song
FROM performance AS pfmc
JOIN band AS b
ON pfmc.gave = b.band_no
JOIN (
  SELECT cmpn.c_no AS songId, m_name AS name, c_title AS song
  FROM musician AS m
  JOIN composer AS cmpr
  ON m.m_no = cmpr.comp_is
  JOIN has_composed AS hc
  ON cmpr.comp_no = hc.cmpr_no
  JOIN composition AS cmpn
  ON hc.cmpn_no = cmpn.c_no
) AS songs_by_composer
ON pfmc.performed = songs_by_composer.songId
WHERE songs_by_composer.name = 'Sue Little'
ORDER BY band;

/*
+---------------------+-----------------------+
|        band         |          song         |
+---------------------+-----------------------+
| BBSO                | Slow Symphony Blowing |
| BBSO                | Slow Song             |
| Somebody Loves this | Slow Symphony Blowing |
| Swinging strings    | Slow Song             |
| The left Overs      | Slow Song             |
+---------------------+-----------------------+
*/
