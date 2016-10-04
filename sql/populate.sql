/* Populate publication table using publication.csv */
COPY Publication(category, key, mdate, publtype, reviewid, rating, title, booktitle, pages, year, address, journal, volume, number, month, school, chapter) FROM '/Users/prajogotio/proj/cz4031/dbstuffsocool31/dblp_xml_parser/publication.csv' CSV;

/* Load publisher.csv into temporary table */
DROP TABLE IF EXISTS PublisherCSV;
CREATE TEMP TABLE PublisherCSV (
  publication_key TEXT NOT NULL,
  publisher_name TEXT NOT NULL
);
COPY PublisherCSV FROM '/Users/prajogotio/proj/cz4031/dbstuffsocool31/dblp_xml_parser/publisher.csv' CSV;

/* Populate the publisher table */
DELETE FROM Publisher;
INSERT INTO Publisher(name)
SELECT DISTINCT publisher_name FROM PublisherCSV;

/* Update the publisher information in publication table */
UPDATE Publication SET publisher_id = temp.publisher_id
FROM (
SELECT pub2.publication_id pub_id, p.publisher_id publisher_id FROM Publication pub2
JOIN PublisherCSV pcsv ON pub2.key = pcsv.publication_key
JOIN Publisher p ON pcsv.publisher_name = p.name
) temp
WHERE publication_id = temp.pub_id;

/* The last thing to do. This will take a very long time.
ALTER TABLE Publication ADD UNIQUE (key);
*/