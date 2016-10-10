---------------------------------START QN 5-----------------------------------
-- Question 5
-- Twice faster?
SELECT
  CAST((year - 1970)/5 * 5 + 1970 AS TEXT) || ' - ' ||
  CAST((year - 1970)/5 * 5 + 1974 AS TEXT) AS year_range, COUNT(publication_id)
FROM Publication
WHERE year >= 1970
GROUP BY (year - 1970)/5
ORDER BY year_range;
/*
 year_range  |  count  
-------------+---------
 1970 - 1974 |   13486
 1975 - 1979 |   22355
 1980 - 1984 |   38638
 1985 - 1989 |   72984
 1990 - 1994 |  148961
 1995 - 1999 |  250245
 2000 - 2004 |  451840
 2005 - 2009 |  860318
 2010 - 2014 | 1159497
 2015 - 2019 |  397562
(10 rows)

Query Plan Generated:
 Sort  (cost=156741.34..156741.50 rows=64 width=8) (actual time=3504.693..3504.693 rows=10 loops=1)
   Sort Key: (((((((((year - 1970) / 5)) * 5) + 1970))::text || ' - '::text) || ((((((year - 1970) / 5)) * 5) + 1974))::text))
   Sort Method: quicksort  Memory: 25kB
   ->  HashAggregate  (cost=156736.22..156739.42 rows=64 width=8) (actual time=3504.634..3504.648 rows=10 loops=1)
         Group Key: ((year - 1970) / 5)
         ->  Seq Scan on publication  (cost=0.00..139657.19 rows=3415806 width=8) (actual time=0.019..2280.831 rows=3415886 loops=1)
               Filter: (year >= 1970)
               Rows Removed by Filter: 11967
 Planning time: 0.198 ms
 Execution time: 3504.767 ms
(10 rows)

Time: 3505.544 ms
*/

-- What is the effect of using Btree index? Below is the experiment.
-- By setting enable_seqscan to off, we kind of force Postgres query planner
-- to use the Btree index.
SET enable_seqscan=off;
EXPLAIN ANALYZE
SELECT
  CAST((year - 1970)/5 * 5 + 1970 AS TEXT) || ' - ' ||
  CAST((year - 1970)/5 * 5 + 1974 AS TEXT) AS year_range, COUNT(publication_id)
FROM Publication
WHERE year >= 1970
GROUP BY (year - 1970)/5
ORDER BY year_range;
SET enable_seqscan=on;

/*
Generated Query Plan:
 Sort  (cost=220535.68..220535.84 rows=64 width=8) (actual time=4515.394..4515.395 rows=10 loops=1)
   Sort Key: (((((((((year - 1970) / 5)) * 5) + 1970))::text || ' - '::text) || ((((((year - 1970) / 5)) * 5) + 1974))::text))
   Sort Method: quicksort  Memory: 25kB
   ->  HashAggregate  (cost=220530.56..220533.76 rows=64 width=8) (actual time=4515.337..4515.348 rows=10 loops=1)
         Group Key: ((year - 1970) / 5)
         ->  Bitmap Heap Scan on publication  (cost=63944.93..203451.53 rows=3415806 width=8) (actual time=813.053..3284.606 rows=3415886 loops=1)
               Recheck Cond: (year >= 1970)
               Rows Removed by Index Recheck: 7809
               Heap Blocks: exact=26739 lossy=52858
               ->  Bitmap Index Scan on pub_year_index  (cost=0.00..63090.97 rows=3415806 width=0) (actual time=762.421..762.421 rows=3415886 loops=1)
                     Index Cond: (year >= 1970)
 Planning time: 0.193 ms
 Execution time: 4515.512 ms (Kind of slower!)
(13 rows)
*/

--------------------------------- END OF QN 5 --------------------------------
---------------------------------START QN 6-----------------------------------


-- Question 6
-- Faster by 1.5x? By changing FROM T1, T2 WHERE T1.attr = T2.attr
-- to FROM T1 JOIN T2 ON T1.attr = T2.attr, we can let the query planner to
-- use faster join algorithms, which can be faster than merge sort strategies.
SELECT q1.name AS author, q2.collaborators_count 
FROM (SELECT * FROM author) as q1
JOIN (SELECT PA1.author_id AS author_id,
             COUNT(DISTINCT PA2.author_id) AS collaborators_count 
      FROM publicationauthor PA1
      JOIN publicationauthor PA2
      ON PA1.author_id!=PA2.author_id
         AND PA1.publication_id=PA2.publication_id 
      GROUP BY PA1.author_id) as q2
ON q1.author_id=q2.author_id
ORDER BY collaborators_count DESC LIMIT 10;
/*
   author   | collaborators_count 
------------+---------------------
  Wei Wang  |                2126
  Wei Zhang |                1885
  Wei Li    |                1732
  Yang Liu  |                1612
  Jing Li   |                1580
  Jun Wang  |                1564
  Li Zhang  |                1551
  Yu Zhang  |                1509
  Lei Zhang |                1476
  Lei Wang  |                1475
(10 rows)

Time: 127160.173 ms

Generated query plan:
 Limit  (cost=20083932.84..20083932.87 rows=10 width=24)
   ->  Sort  (cost=20083932.84..20084464.33 rows=212595 width=24)
         Sort Key: (count(DISTINCT pa2.author_id))
         ->  Merge Join  (cost=19282084.68..20079338.74 rows=212595 width=24)
               Merge Cond: (pa1.author_id = author.author_id)
               ->  GroupAggregate  (cost=19282084.25..20011840.58 rows=212595 width=8)
                     Group Key: pa1.author_id
                     ->  Sort  (cost=19282084.25..19524627.71 rows=97017384 width=8)
                           Sort Key: pa1.author_id
                           ->  Merge Join  (cost=0.87..2432646.74 rows=97017384 width=8)
                                 Merge Cond: (pa1.publication_id = pa2.publication_id)
                                 Join Filter: (pa1.author_id <> pa2.author_id)
                                 ->  Index Only Scan using pub_author on publicationauthor pa1  (cost=0.43..355152.77 rows=9810468 width=8)
                                 ->  Materialize  (cost=0.43..379678.94 rows=9810468 width=8)
                                       ->  Index Only Scan using pub_author on publicationauthor pa2  (cost=0.43..355152.77 rows=9810468 width=8)
               ->  Index Scan using author_pkey on author  (cost=0.43..58218.44 rows=1798534 width=20)

Down from previous timing using FROM ... WHERE ... shown below:
   author   | collaborators_count 
------------+---------------------
  Wei Wang  |                2126
  Wei Zhang |                1885
  Wei Li    |                1732
  Yang Liu  |                1612
  Jing Li   |                1580
  Jun Wang  |                1564
  Li Zhang  |                1551
  Yu Zhang  |                1509
  Lei Zhang |                1476
  Lei Wang  |                1475
(10 rows)

Time: 187707.260 ms
*/

-----------------------------------------------------------------------------
-- Qn 4b
-- LEFT JOIN and IS NULL check is faster than NOT IN
SELECT author_1.name
FROM (
  SELECT a.author_id, a.name
  FROM Author a
  JOIN PublicationAuthor pa ON pa.author_id = a.author_id
  JOIN Publication p ON p.publication_id = pa.publication_id
  WHERE p.key LIKE '%pvldb%'
) author_1
LEFT JOIN (
  SELECT a.author_id, a.name
  FROM Author a
  JOIN PublicationAuthor pa ON pa.author_id = a.author_id
  JOIN Publication p ON p.publication_id = pa.publication_id
  WHERE p.key LIKE '%kdd%'
) author_2
ON author_1.author_id = author_2.author_id
WHERE author_2.author_id IS NULL
GROUP BY author_1.name
HAVING COUNT(*) >= 10;