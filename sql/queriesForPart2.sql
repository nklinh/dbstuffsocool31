-- POSTGRESQL for running queries in part 2.
\timing on 

\echo Questions 1:
SELECT DISTINCT category, COUNT(publication_id) 
FROM publication 
GROUP BY category;
\echo 
\echo


\echo Question 2:
SELECT q1.name AS author, q2.publication_count 
FROM author as q1, (
	SELECT author_id, COUNT(*) AS publication_count 
	FROM publicationauthor 
	GROUP BY author_id
	ORDER BY publication_count DESC 
	LIMIT 10) as q2 
WHERE q1.author_id=q2.author_id
ORDER BY publication_count DESC; 
\echo
\echo


\echo Question 3a:
SELECT P.title as Title, A.name as Author, P.year as Year 
FROM publication P, publicationauthor PA, author A 
WHERE A.name = ' Takanobu Otsuka' 
	AND A.author_id=PA.author_id 
	AND PA.publication_id=P.publication_id 
	AND P.year=2012;
\echo
\echo


\echo Question 3b:
SELECT A.name,P.year,P.title 
FROM author A, publicationauthor PA, publication P 
WHERE A.author_id=PA.author_id 
	AND PA.publication_id=P.publication_id 
	AND A.name = ' Florian Skopik' 
	AND P.year=2015 
	AND P.key LIKE 'conf/cybersa%';
\echo
\echo


\echo Question 3c:
SELECT A.name 
FROM author A, publicationauthor PA, publication P 
WHERE A.author_id=PA.author_id 
	AND PA.publication_id=P.publication_id 
	AND P.year=2015 
	AND P.key LIKE 'conf/cybersa%' 
GROUP BY A.name 
HAVING COUNT(P.key)>=2;
\echo
\echo


\echo Question 4a:
SELECT A.name 
FROM author A, publicationauthor PA, publication P 
WHERE A.author_id=PA.author_id 
	AND PA.publication_id=P.publication_id 
	AND P.key LIKE '%sigmod%' AND A.name IN (
		SELECT A.name 
		FROM author A, publicationauthor PA, publication P 
		WHERE A.author_id=PA.author_id 
			AND PA.publication_id=P.publication_id 
			AND P.key LIKE '%pvldb%' 
		GROUP BY A.name 
		HAVING COUNT(P.key)>=10) 
GROUP BY A.name 
HAVING COUNT(P.key)>=10;
\echo
\echo


\echo Question 4b:
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
\echo
\echo


\echo Question 5:
SELECT
  CAST((year - 1970)/5 * 5 + 1970 AS TEXT) || ' - ' ||
  CAST((year - 1970)/5 * 5 + 1974 AS TEXT) AS year_range, COUNT(publication_id)
FROM Publication
WHERE year >= 1970
GROUP BY (year - 1970)/5
ORDER BY year_range;
\echo
\echo


\echo Question 6:
SELECT q1.name AS author, q2.collaborators_count 
FROM author as q1
JOIN (SELECT PA1.author_id AS author_id,
             COUNT(DISTINCT PA2.author_id) AS collaborators_count 
      FROM publicationauthor PA1
      JOIN publicationauthor PA2
      ON PA1.author_id!=PA2.author_id
         AND PA1.publication_id=PA2.publication_id 
      GROUP BY PA1.author_id
      ORDER BY collaborators_count DESC 
      LIMIT 10) as q2
ON q1.author_id=q2.author_id
ORDER BY collaborators_count DESC ;
\echo
\echo


\echo Question 7:
SELECT q1.name AS author, q2.publication_count 
FROM author as q1, (
	SELECT author_id, COUNT(PA.*) AS publication_count 
	FROM publicationauthor PA, publication p
	WHERE (P.key LIKE 'journals/%' OR P.key LIKE 'conf/%')
		AND LOWER(P.title) LIKE '%data%' 
		AND p.year BETWEEN 2012 AND 2016
		AND p.publication_id = PA.publication_id
	GROUP BY author_id
	ORDER BY publication_count DESC 
	LIMIT 10) as q2 
WHERE q1.author_id=q2.author_id
ORDER BY publication_count DESC;
\echo
\echo


\echo Question 8:
\echo Question: Find the top 10 authors with the largest
\echo number of publications in a selected period of years.
SELECT q1.name AS author, q2.publication_count 
FROM author as q1, (
	SELECT author_id, COUNT(PA.*) AS publication_count 
	FROM publicationauthor PA, publication p
	WHERE p.year BETWEEN 1960 AND 1969
		AND p.publication_id = PA.publication_id
	GROUP BY author_id
	ORDER BY publication_count DESC 
	LIMIT 10) as q2 
WHERE q1.author_id=q2.author_id
ORDER BY publication_count DESC;
\echo
\echo


\echo Question 9:
\echo Question: Find the pair of authors who produced 
\echo the most number of papers together.

WITH collaborators AS
	(SELECT PA1.author_id AS author_id_1, 
		PA2.author_id AS author_id_2,
		COUNT(*) AS papers_count 
	FROM publicationauthor PA1, publicationauthor PA2 
	WHERE PA1.author_id!=PA2.author_id 
		AND PA1.publication_id=PA2.publication_id 
	GROUP BY PA1.author_id, PA2.author_id
	ORDER BY COUNT(*) DESC
	LIMIT 1)	
SELECT A1.name AS author_1, A2.name AS author_2, C.papers_count
FROM collaborators C
INNER JOIN author A1 
ON A1.author_id = C.author_id_1
INNER JOIN author A2
ON A2.author_id = C.author_id_2;