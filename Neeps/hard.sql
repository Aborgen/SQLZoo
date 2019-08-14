-- Neeps Hard Questions
-- https://zh.sqlzoo.net/wiki/Neeps_hard_questions

-- 11)
-- co.CHt is to be given all the teaching that co.ACg currently does.
-- Identify those events which will clash.
WITH all_events (teacherId, eventId, day, start_time, end_time) AS
(
  SELECT t.staff, t.event, dow, tod, CONCAT(tod + duration, ':00')
  FROM teaches AS t
  JOIN event AS e
  ON t.event = e.id
)

SELECT event, conflict_event, day, event_start, event_end, conflict_start, conflict_end
FROM (
  SELECT eventId AS event, ae.day, ae.start_time AS event_start,
         ae.end_time AS event_end, conflict.id AS conflict_event,
         conflict.start_time AS conflict_start, conflict.end_time AS conflict_end
  FROM all_events AS ae
  JOIN (
    SELECT eventId AS id, day, start_time, end_time
    FROM all_events AS ae2
    WHERE ae2.teacherId = 'co.ACg'
  ) AS conflict
  ON conflict.day = ae.day AND
  (
    conflict.start_time BETWEEN ae.start_time AND
                                ae.end_time
    OR
    ae.start_time BETWEEN conflict.start_time AND
                          conflict.end_time
  )
  WHERE ae.teacherId = 'co.CHt'
) AS events
WHERE conflict_event IS NOT NULL;

/*
+-------------+----------------+---------+-------------+-----------+----------------+--------------+
|    event    | conflict_event |   day   | event_start | event_end | conflict_start | conflict_end |
+-------------+----------------+---------+-------------+-----------+----------------+--------------+
| co12005.T03 | co12005.T01    | Tuesday |       10:00 |     12:00 |          11:00 |        13:00 |
| co12005.T03 | co42010.T01    | Tuesday |       10:00 |     12:00 |          12:00 |        13:00 |
| co12005.T03 | co72013.L02    | Tuesday |       10:00 |     12:00 |          09:00 |        11:00 |
| co12005.T03 | co72013.T03    | Tuesday |       10:00 |     12:00 |          11:00 |        12:00 |
| co72021.L01 | co12005.T01    | Tuesday |       13:00 |     15:00 |          11:00 |        13:00 |
| co72021.L01 | co42010.T01    | Tuesday |       13:00 |     15:00 |          12:00 |        13:00 |
+-------------+----------------+---------+-------------+-----------+----------------+--------------+
*/

-- 12)
-- Produce a table showing the utilisation rate and the occupancy level for all rooms with a capacity more than 60.
               (Hours spent in class in room) divided by (total number of available hours)
Utilization: 

               (Butts in seats)  divided by  (total amount of seats across classes
Occupancy: SUM("Studnets in attends") / (capacity * COUNT("Events using room")