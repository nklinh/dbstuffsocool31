-- POSTGRESQL for running queries in part 2.
\timing on

\echo Questions 1:
SELECT DISTINCT category,COUNT(category) 
FROM publication 
GROUP BY category;


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


\echo Question 3a:
SELECT P.title as Title, A.name as Author, P.year as Year 
FROM publication P, publicationauthor PA, author A 
WHERE A.name = ' Takanobu Otsuka' 
	AND A.author_id=PA.author_id 
	AND PA.publication_id=P.publication_id 
	AND P.year=2012;


\echo Question 3b:
SELECT A.name,P.year,P.title 
FROM author A, publicationauthor PA, publication P 
WHERE A.author_id=PA.author_id 
	AND PA.publication_id=P.publication_id 
	AND A.name = ' Florian Skopik' 
	AND P.year=2015 
	AND P.key LIKE 'conf/cybersa%';


\echo Question 3c:
SELECT A.name 
FROM author A, publicationauthor PA, publication P 
WHERE A.author_id=PA.author_id 
	AND PA.publication_id=P.publication_id 
	AND P.year=2015 
	AND P.key LIKE 'conf/cybersa%' 
GROUP BY A.name 
HAVING COUNT(P.key)>=2;


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


\echo Question 4b:
SELECT A.name 
FROM author A, publicationauthor PA, publication P 
WHERE A.author_id=PA.author_id 
	AND PA.publication_id=P.publication_id 
	AND P.key LIKE '%pvldb%' 
	AND A.name NOT IN (
		SELECT A.name 
		FROM author A, publicationauthor PA, publication P 
		WHERE A.author_id=PA.author_id 
			AND PA.publication_id=P.publication_id 
			AND P.key 	LIKE '%kdd%') 
GROUP BY A.name 
HAVING COUNT(P.key)>=10;


\echo Question 5:
\echo Method 1:
SELECT                                                                                
CASE
	when year = null then 'NULL'                                                                        	
	when year between 1970 and 1974 then '1970-1974'                                                	
	when year between 1975 and 1979 then '1975-1979'                                                	
	when year between 1980 and 1984 then '1980-1984'                                                	
	when year between 1985 and 1989 then '1985-1989'                                                	
	when year between 1990 and 1994 then '1990-1994'                                                	
	when year between 1995 and 1999 then '1995-1999'                                                	
	when year between 2000 and 2004 then '2000-2004'                                                	
	when year between 2005 and 2009 then '2005-2009'                                                	
	when year between 2010 and 2014 then '2010-2014'                                                	
	when year between 2015 and 2019 then '2015-2019'                                        
	end as years, count(*) 
FROM publication                                                                             
GROUP BY years
ORDER BY years;

\echo Method 2:
WITH ranges AS (
	SELECT (five*5)::text||'-'||(five*5+4)::text AS range,         
    	five*5 AS r_min, five*5+4 AS r_max
    FROM generate_series(394, 403) AS f(five))
SELECT r.range, count(p.*)
FROM ranges r
LEFT JOIN publication p ON p.year BETWEEN r.r_min AND r.r_max
GROUP BY r.range
ORDER BY r.range;


\echo Question 6:
SELECT q1.name AS author, q2.collaborators_count 
FROM author as q1, (
	SELECT PA1.author_id AS author_id,
		COUNT(DISTINCT PA2.author_id) AS collaborators_count 
	FROM publicationauthor PA1, publicationauthor PA2 
	WHERE PA1.author_id!=PA2.author_id 
		AND PA1.publication_id=PA2.publication_id 
	GROUP BY PA1.author_id
	ORDER BY collaborators_count DESC 
	LIMIT 10) as q2 
WHERE q1.author_id=q2.author_id 
ORDER BY collaborators_count DESC;


\echo Question 7:
SELECT A.name, COUNT(*) AS publication_count 
FROM author A, publication P, publicationauthor PA 
WHERE P.publication_id=PA.publication_id 
	AND A.author_id=PA.author_id 
	AND (P.key LIKE 'journals/%' OR P.key LIKE 'conf/%') 
	AND P.year BETWEEN 2012 AND 2016 
	AND P.title LIKE '%data%' 
GROUP BY A.name 
ORDER BY count(*) DESC 
LIMIT 10;


\echo Question 8:
\echo Question: Find the top 10 authors with the largerst
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