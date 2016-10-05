-- Populate publication table using publication.csv.
COPY Publication(category, key, mdate, publtype, reviewid, rating, title, booktitle, pages, year, address, journal, volume, number, month, school, chapter) FROM '/Users/prajogotio/proj/cz4031/dbstuffsocool31/dblp_xml_parser/publication.csv' CSV;

-- Load publisher.csv into temporary table.
DROP TABLE IF EXISTS PublisherCSV;
CREATE TEMP TABLE PublisherCSV (
  publication_key TEXT NOT NULL,
  publisher_name TEXT NOT NULL
);
COPY PublisherCSV FROM '/Users/prajogotio/proj/cz4031/dbstuffsocool31/dblp_xml_parser/publisher.csv' CSV;

-- Populate the publisher table.
DELETE FROM Publisher;
INSERT INTO Publisher(name)
SELECT DISTINCT publisher_name FROM PublisherCSV;

-- Update the publisher information in publication table.
UPDATE Publication SET publisher_id = temp.publisher_id
FROM (
SELECT pub2.publication_id pub_id, p.publisher_id publisher_id FROM Publication pub2
JOIN PublisherCSV pcsv ON pub2.key = pcsv.publication_key
JOIN Publisher p ON pcsv.publisher_name = p.name
) temp
WHERE publication_id = temp.pub_id;

DROP TABLE PublisherCSV;


-- Load author.csv.
DROP TABLE IF EXISTS AuthorCSV;
CREATE TEMP TABLE AuthorCSV (
  publication_key TEXT NOT NULL,
  author_name TEXT NOT NULL
);
COPY AuthorCSV FROM '/Users/prajogotio/proj/cz4031/dbstuffsocool31/dblp_xml_parser/author.csv' CSV;

-- Populate Author table. Assumption: author names are unique.
DELETE FROM Author;
EXPLAIN ANALYZE
INSERT INTO Author(name)
SELECT DISTINCT author_name FROM AuthorCSV;

-- Populate PublicationAuthor table.
DELETE FROM PublicationAuthor;
EXPLAIN ANALYZE
INSERT INTO PublicationAuthor
SELECT DISTINCT pub.publication_id, a.author_id
FROM Author a
JOIN AuthorCSV acsv ON a.name = acsv.author_name
JOIN Publication pub ON pub.key = acsv.publication_key;
DROP TABLE AuthorCSV;

-- Load editor.csv.
DROP TABLE IF EXISTS EditorCSV;
CREATE TEMP TABLE EditorCSV (
  publication_key TEXT NOT NULL,
  editor_name TEXT NOT NULL
);
COPY EditorCSV FROM '/Users/prajogotio/proj/cz4031/dbstuffsocool31/dblp_xml_parser/editor.csv' CSV;

-- Insert editor names that have not been added into Author table.
INSERT INTO Author(name)
SELECT DISTINCT editor_name FROM EditorCSV
WHERE NOT EXISTS (SELECT 1 FROM Author a WHERE a.name = editor_name);

-- Populate PublicationEditor table.
INSERT INTO PublicationEditor
SELECT DISTINCT pub.publication_id, a.author_id
FROM Author a
JOIN EditorCSV csv ON a.name = csv.editor_name
JOIN Publication pub ON pub.key = csv.publication_key;

DROP TABLE EditorCSV;