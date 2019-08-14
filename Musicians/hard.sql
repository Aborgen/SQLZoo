-- Musicians Hard Questions
-- https://zh.sqlzoo.net/wiki/Musicians_hard_questions

-- 11)
-- List the name and town of birth of any performer born in the same city as James First. 
WITH performing_musicians (name, hometown) AS
(
  SELECT DISTINCT m.m_name, plc.place_town
  FROM performer AS pfmr
  JOIN musician AS m
  ON pfmr.perf_is = m.m_no
  JOIN place AS plc
  ON m.born_in = plc.place_no
)

SELECT name, hometown
FROM performing_musicians AS pm
WHERE pm.hometown = (
  SELECT hometown
  FROM performing_musicians
  WHERE name = 'James First'
) AND name <> 'James First';

/*
+-------------+----------+
|     name    | hometown |
+-------------+----------+
| Theo Mengel | London   |
| Alan Fluff  | London   |
+-------------+----------+
*/

-- 12)
-- Create a list showing for EVERY musician born in Britain the
-- number of compositions and the number of instruments played.
SELECT m_name AS name, compositions, instrumentsPlayed
FROM musician AS m
JOIN place AS plc
ON m.born_in = plc.place_no
JOIN (
  SELECT m_no AS musicianId, COUNT(hc.cmpn_no) AS compositions
  FROM musician AS m
  LEFT JOIN composer AS cmpr
  ON m.m_no = cmpr.comp_is
  LEFT JOIN has_composed AS hc
  ON cmpr.comp_no = hc.cmpr_no
  GROUP BY musicianId) AS compositions_per_musician
ON m.m_no = compositions_per_musician.musicianId
JOIN (
  SELECT m_no AS musicianId, COUNT(instrument) AS instrumentsPlayed
  FROM musician AS m
  LEFT JOIN performer AS p
  ON m.m_no = p.perf_is
  GROUP BY musicianId) AS instruments_played
ON m.m_no = instruments_played.musicianId
WHERE plc.place_country = 'England';

/*
+------------------+--------------+-------------------+
|       name       | compositions | instrumentsPlayed |
+------------------+--------------+-------------------+
| Fred Bloggs      |            2 |                 0 |
| Harriet Smithson |            0 |                 2 |
| James First      |            4 |                 1 |
| Theo Mengel      |            0 |                 3 |
| Harry Forte      |            2 |                 3 |
| Davis Heavan     |            0 |                 3 |
| Alan Fluff       |            0 |                 2 |
| Andy Jones       |            1 |                 0 |
| James Steeple    |            0 |                 0 |
+------------------+--------------+-------------------+
*/

-- 13)
-- Give the band name, conductor and contact of the bands performing
-- at the most recent concert in the Royal Albert Hall.
SELECT band, m.m_name AS conductor, contact
FROM (
  SELECT concert_no AS id
  FROM concert AS c
  WHERE c.concert_venue = 'Royal Albert Hall'
  ORDER BY con_date DESC
  LIMIT 1
) AS last_concert
JOIN performance AS pfmc
ON last_concert.id = pfmc.gave
JOIN musician AS m
ON pfmc.conducted_by = m.m_no
JOIN (
  SELECT band_no AS id, band_name AS band, m_name AS contact
  FROM band AS b
  JOIN musician AS m
  ON b.band_contact = m.m_no) AS all_bands
ON pfmc.performed_in = all_bands.id;

/*
+---------------------+------------+-------------+
|         band        |  conductor |   contact   |
+---------------------+------------+-------------+
| Somebody Loves this | Alan Fluff | Theo Mengel |
+---------------------+------------+-------------+
*/

-- 14)
-- Give a list of musicians associated with Glasgow. Include the name of the musician and the
-- nature of the association - one or more of 'LIVES_IN', 'BORN_IN', 'PERFORMED_IN' AND 'IN_BAND_IN'.
SET @locationId = (
  SELECT place_no
  FROM place
  WHERE place_town = 'Glasgow'
);

SELECT name, LIVES_IN, BORN_IN, PLAYED_IN, IN_BAND_IN
FROM (
  SELECT m_name AS name, IF(living_in = @locationId, 1, 0) AS LIVES_IN, IF(born_in = @locationId, 1, 0) AS BORN_IN,
         played_in.status AS PLAYED_IN, band_in.status AS IN_BAND_IN
  FROM musician AS m
  JOIN (
    -- MAX is here to remove duplicates. A musician can be a member of
    -- any number of bands; we are only concerned with knowing whether
    -- they are part of at least one based out of the specified location.
    SELECT m_no AS id, MAX(IF(band_home = @locationId, 1, 0)) AS status
    FROM musician AS m
    LEFT JOIN plays_in AS pi
    ON m.m_no = pi.player
    LEFT JOIN band AS b
    ON pi.band_id = b.band_no
    GROUP BY id) AS band_in
  ON m.m_no = band_in.id
  JOIN (
    -- Similar reasoning as above.
    SELECT m_no AS id, MAX(IF(concert_in = @locationId, 1, 0)) AS status
    FROM musician AS m
    LEFT JOIN performance AS pfmc
    ON m.m_no = pfmc.performed_in
    LEFT JOIN concert AS c
    ON pfmc.gave = c.concert_no
    GROUP BY id) AS played_in
  ON m.m_no = played_in.id
) AS musician_location_info
WHERE LIVES_IN + BORN_IN + PLAYED_IN + IN_BAND_IN > 0;

/*
+------------------+----------+---------+-----------+------------+
|       name       | LIVES_IN | BORN_IN | PLAYED_IN | IN_BAND_IN |
+------------------+----------+---------+-----------+------------+
| Harriet Smithson |        1 |       0 |         0 |          0 |
| Jeff Dawn        |        1 |       0 |         0 |          1 |
| Davis Heavan     |        0 |       0 |         0 |          1 |
| Lovely Time      |        0 |       1 |         0 |          1 |
| Alan Fluff       |        0 |       0 |         0 |          1 |
| Tony Smythe      |        0 |       0 |         0 |          1 |
| Freda Miles      |        0 |       0 |         0 |          1 |
| Elsie James      |        0 |       0 |         0 |          1 |
| Andy Jones       |        1 |       0 |         0 |          0 |
| Louise Simpson   |        1 |       1 |         0 |          0 |
| James Steeple    |        1 |       0 |         0 |          0 |
| Steven Chaytors  |        0 |       1 |         0 |          0 |
+------------------+----------+---------+-----------+------------+
*/

-- 15)
-- Jeff Dawn plays in a band with someone who plays in a band with Sue Little.
-- Who is it and what are the bands?
WITH musicians_bands (musicianId, name, bandId, band) AS
(
  SELECT m_no, m_name, band_no, band_name
  FROM musician AS m
  JOIN plays_in AS pi
  ON m.m_no = pi.player
  JOIN band AS b
  ON pi.band_id = b.band_no
)

SELECT m1.name, m1.band AS 'Dawn\'s', m2.band AS 'Little\'s'
FROM (
  SELECT musicianId, name, bandId, band
  FROM musicians_bands
  WHERE bandId = ANY (
    SELECT bandId
    FROM musicians_bands
    WHERE name = 'Jeff Dawn'
  ) AND name <> 'Jeff Dawn') AS m1
JOIN (
  SELECT musicianId, name, bandId, band
  FROM musicians_bands
  WHERE bandId = ANY (
    SELECT bandId
    FROM musicians_bands
    WHERE name = 'Sue Little'
  ) AND name <> 'Sue Little') AS m2
ON m1.musicianId = m2.musicianId;

/*
NOTE:
There doesn't appear to be such a person within the given data!
So, I tested this query with the names Jeff Dawn and Tony Smythe,
which gives us some results. Alan Fluff plays with Dawn and Smythe in AASO.
We also see Fluff acting as an "in-between," where he connects Dawn and Smythe
through two distinct bands, much like the non-existant person who provides a
connection between Dawn and Little.
      
+--------------+----------+------------------+
|     name     |  Dawn's  |     Little's     |
+--------------+----------+------------------+
|              |          |                  |
+--------------+----------+------------------+
  
+--------------+----------+------------------+
|     name     |  Dawn's  |     Smythe's     |
+--------------+----------+------------------+
| Davis Heavan | AASO     | AASO             |
| Lovely Time  | AASO     | AASO             |
| Alan Fluff   | AASO     | AASO             |
| Alan Fluff   | AASO     | Swinging strings |
| Freda Miles  | AASO     | AASO             |
| Elsie James  | AASO     | AASO             |
+--------------+----------+------------------+
*/
