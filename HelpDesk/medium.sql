-- Helpdesk Medium Questions
-- https://zh.sqlzoo.net/wiki/Helpdesk_Medium_Questions

-- 6)
-- List the Company name and the number of calls for those companies with more than 18 calls.
SELECT cst.Company_name, COUNT(*) AS cc
FROM Issue AS i
JOIN Caller AS clr
ON i.Caller_id = clr.Caller_id
JOIN Customer AS cst
ON clr.Company_ref = cst.Company_ref
GROUP BY cst.Company_name
HAVING COUNT(*) > 18;

/*
+------------------+----+
|   Company_name   | cc |
+------------------+----+
| Gimmick Inc.     | 22 |
| Hamming Services | 19 |
| High and Co.     | 20 |
+------------------+----+
*/

-- 7)
-- Find the callers who have never made a call.
-- Show first name and last name
SELECT clr.first_name, clr.last_name
FROM Caller AS clr
WHERE clr.Caller_id NOT IN (
  SELECT Caller_id FROM Issue
);

/*
+------------+-----------+
| first_name | last_name |
+------------+-----------+
| David      | Jackson   |
| Ethan      | Phillips  |
+------------+-----------+
*/

-- 8)
-- For each customer show:
-- Company name, contact name, number of calls where the number of calls is fewer than 5
SELECT cst.Company_name, clr.first_name, clr.last_name, COUNT(*) AS nc
FROM Customer AS cst
JOIN Caller AS clr
ON cst.Contact_id = clr.Caller_id
JOIN (
  SELECT i2.Call_ref, clr2.Company_ref  -- This is necessary, since we need to count all calls
  FROM Issue As i2                      -- made on behalf of each Customer, which are not always
  JOIN Caller AS clr2                   -- made by the assigned contact (Customer.Contact_id):
  ON i2.Caller_id = clr2.Caller_id      -- e.g. 'Somebody Logistics' has made two calls, both
) AS all_calls                          -- made by Emma Hall, while the contact, Ethan Phillips,
                                        -- has made none.
ON all_calls.Company_ref = cst.Company_ref
GROUP BY Company_name, first_name, last_name
HAVING COUNT(*) < 5;

/*
+--------------------+------------+-----------+----+
|    Company_name    | first_name | last_name | nc |
+--------------------+------------+-----------+----+
| Pitiable Shipping  | Ethan      | McConnell |  4 |
| Rajab Group        | Emily      | Cooper    |  4 |
| Somebody Logistics | Ethan      | Phillips  |  2 |
+--------------------+------------+-----------+----+
*/

-- 9)
-- For each shift show the number of staff assigned.
-- Beware that some roles may be NULL and that the same person might have been
-- assigned to multiple roles (The roles are 'Manager', 'Operator', 'Engineer1', 'Engineer2').
----   NOTE: I had to look for help on this one... the solution was not obvious to me at all.
----         I could easily count each non-null role by converting each to a boolean with NOT NULL
----         and then subsequently adding the result, but I was stuck as to how to avoid potentially
----         counting the same value twice within each row.
----   https://github.com/lilyz622/sqlzoo-assessments-solutions/blob/master/Helpdesk_Medium_Questions/9_persons_per_shift.sql
SELECT Shift_date, Shift_type, COUNT(DISTINCT role)
FROM (
  ( SELECT Shift_date, Shift_type, Manager   AS role FROM Shift )
  UNION
  ( SELECT Shift_date, Shift_type, Operator  AS role FROM Shift )
  UNION
  ( SELECT Shift_date, Shift_type, Engineer1 AS role FROM Shift )
  UNION
  ( SELECT Shift_date, Shift_type, Engineer2 AS role FROM Shift )
) AS all_roles
GROUP BY Shift_date, Shift_type;

/*
+------------+------------+----+
| Shift_date | Shift_type | cw |
+------------+------------+----+
| 2017-08-12 | Early      |  4 |
| 2017-08-12 | Late       |  4 |
| 2017-08-13 | Early      |  3 |
| 2017-08-13 | Late       |  2 |
| 2017-08-14 | Early      |  4 |
| 2017-08-14 | Late       |  4 |
| 2017-08-15 | Early      |  4 |
| 2017-08-15 | Late       |  4 |
| 2017-08-16 | Early      |  4 |
| 2017-08-16 | Late       |  4 |
+------------+------------+----+
*/

-- 10)
-- Caller 'Harry' claims that the operator who took his most recent call was abusive and insulting.
-- Find out who took the call (full name) and when.
SELECT sff.first_name, sff.last_name, i.call_date
FROM Caller AS clr
JOIN Issue AS i
ON clr.Caller_id = i.Caller_id
JOIN Staff AS sff
ON i.Taken_by = sff.Staff_code
WHERE clr.first_name = 'Harry'
ORDER BY call_date DESC
LIMIT 1;

/*
+------------+-----------+---------------------+
| first_name | last_name |      call_date      |
+------------+-----------+---------------------+
| Emily      | Best      | 2017-08-16 10:25:00 |
+------------+-----------+---------------------+
*/
