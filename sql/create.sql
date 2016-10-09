-- POSTGRESQL for creating and populating tables.
\timing on
-- path_to_csv is the psql environment variable.
-- Change this   vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
\set path_to_csv /Users/youwei/Y4S1/CZ4031_Database/Project/Project_1/csv_half/
--               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-- to the path where you place the csv files. Notice that there is no quotation mark.
\echo Creating tables.
DROP TABLE IF EXISTS Publication;
CREATE TABLE Publication (
  publication_id SERIAL PRIMARY KEY,
  category TEXT NOT NULL,
  key TEXT NOT NULL,
  mdate DATE NOT NULL,
  publtype TEXT,
  reviewid TEXT,
  rating TEXT,
  title TEXT,
  booktitle TEXT,
  pages TEXT,
  year INT,
  address TEXT,
  journal TEXT,
  volume TEXT,
  number TEXT,
  month TEXT,
  publisher_id INT,
  school TEXT,
  chapter INT
);

DROP TABLE IF EXISTS Publisher;
CREATE TABLE Publisher (
  publisher_id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL
);

DROP TABLE IF EXISTS Author;
CREATE TABLE Author (
  author_id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

DROP TABLE IF EXISTS PublicationAuthor;
CREATE TABLE PublicationAuthor (
  publication_id INT NOT NULL,
  author_id INT NOT NULL
);

DROP TABLE IF EXISTS PublicationEditor;
CREATE TABLE PublicationEditor (
  publication_id INT NOT NULL,
  editor_id INT NOT NULL
);

DROP TABLE IF EXISTS Citation;
CREATE TABLE Citation (
  publication_id INT NOT NULL,
  citation_id INT NOT NULL
);

DROP TABLE IF EXISTS PublicationUrl;
CREATE TABLE PublicationUrl (
  publication_id INT NOT NULL,
  url TEXT NOT NULL
);

DROP TABLE IF EXISTS PublicationNote;
CREATE TABLE PublicationNote (
  publication_id INT NOT NULL,
  note TEXT NOT NULL
);

DROP TABLE IF EXISTS PublicationISBN;
CREATE TABLE PublicationISBN (
  publication_id INT NOT NULL,
  isbn TEXT NOT NULL
);

\set path_to_publication_csv '\'' :path_to_csv publication.csv '\''
\echo Populating publication information.
-- Populate publication table using publication.csv.
COPY Publication(category, key, mdate, publtype, reviewid, rating, title, booktitle, pages, year, address, journal, volume, number, month, school, chapter) FROM :path_to_publication_csv CSV;

\set path_to_publisher_csv '\'' :path_to_csv publisher.csv '\''
\echo Populating publisher information.
-- Load publisher.csv into temporary table.
DROP TABLE IF EXISTS PublisherCSV;
CREATE TEMP TABLE PublisherCSV (
  publication_key TEXT NOT NULL,
  publisher_name TEXT NOT NULL
);
COPY PublisherCSV FROM :path_to_publisher_csv CSV;

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

\set path_to_author_csv '\'' :path_to_csv author.csv '\''
\echo Populating author information.
-- Load author.csv.
DROP TABLE IF EXISTS AuthorCSV;
CREATE TEMP TABLE AuthorCSV (
  publication_key TEXT NOT NULL,
  author_name TEXT NOT NULL
);
COPY AuthorCSV FROM :path_to_author_csv CSV;

-- Populate Author table. Assumption: author names are unique.
DELETE FROM Author;
INSERT INTO Author(name)
SELECT DISTINCT author_name FROM AuthorCSV;

-- Populate PublicationAuthor table.
DELETE FROM PublicationAuthor;
INSERT INTO PublicationAuthor
SELECT DISTINCT pub.publication_id, a.author_id
FROM Author a
JOIN AuthorCSV acsv ON a.name = acsv.author_name
JOIN Publication pub ON pub.key = acsv.publication_key;
DROP TABLE AuthorCSV;

\set path_to_editor_csv '\'' :path_to_csv editor.csv '\''
\echo Populating editor information.
-- Load editor.csv.
DROP TABLE IF EXISTS EditorCSV;
CREATE TEMP TABLE EditorCSV (
  publication_key TEXT NOT NULL,
  editor_name TEXT NOT NULL
);
COPY EditorCSV FROM :path_to_editor_csv CSV;

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

\set path_to_cite_csv '\'' :path_to_csv cite.csv '\''
\echo Populate citation information.
-- Load cite.csv.
DROP TABLE IF EXISTS CitationCSV;
CREATE TEMP TABLE CitationCSV (
  publication_key TEXT NOT NULL,
  citation_key TEXT NOT NULL
);
COPY CitationCSV FROM :path_to_cite_csv CSV;


-- Populate Citation table. Citation with '...' key will not match with any
-- publication, so those entries will be ignored in effect.
DELETE FROM Citation;
INSERT INTO Citation
SELECT DISTINCT pub.publication_id, cite.publication_id
FROM CitationCSV ccsv
JOIN Publication pub ON pub.key = trim(ccsv.publication_key)
JOIN Publication cite ON cite.key = trim(ccsv.citation_key);

DROP TABLE CitationCSV;

\set path_to_note_csv '\'' :path_to_csv note.csv '\''
\echo Populate notes.
-- Load note.csv.
DROP TABLE IF EXISTS NoteCSV;
CREATE TEMP TABLE NoteCSV (
  publication_key TEXT NOT NULL,
  note TEXT NOT NULL
);
COPY NoteCSV FROM :path_to_note_csv CSV;

-- Populate PublicationNote table.
INSERT INTO PublicationNote
SELECT pub.publication_id, csv.note
FROM NoteCSV csv
JOIN Publication pub ON pub.key = csv.publication_key;

DROP TABLE NoteCSV;

\set path_to_url_csv '\'' :path_to_csv url.csv '\''
\echo Populate url information.
-- Load url.csv.
DROP TABLE IF EXISTS UrlCSV;
CREATE TEMP TABLE UrlCSV (
  publication_key TEXT NOT NULL,
  url TEXT NOT NULL
);
COPY UrlCSV FROM :path_to_url_csv CSV;

-- Populate PublicationUrl.
DELETE FROM PublicationUrl;
INSERT INTO PublicationUrl
SELECT pub.publication_id, csv.url
FROM UrlCSV csv
JOIN Publication pub ON pub.key = csv.publication_key;

DROP TABLE UrlCSV;

\set path_to_isbn_csv '\'' :path_to_csv isbn.csv '\''
\echo Populate isbn information.
-- Load isbn.csv.
DROP TABLE IF EXISTS IsbnCSV;
CREATE TEMP TABLE IsbnCSV (
  publication_key TEXT NOT NULL,
  isbn TEXT NOT NULL
);
COPY IsbnCSV FROM :path_to_isbn_csv CSV;

-- Populate PublicationISBN table.
INSERT INTO PublicationISBN
SELECT pub.publication_id, csv.isbn
FROM IsbnCSV csv
JOIN Publication pub ON pub.key = csv.publication_key;

DROP TABLE IsbnCSV;

\echo Done.