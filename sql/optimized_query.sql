-- Question 5
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

-- Force use Btree index on year
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
 Execution time: 4515.512 ms
(13 rows)
*/
