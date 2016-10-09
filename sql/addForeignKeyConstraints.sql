\timing on
-- Many-to-one
ALTER TABLE publication ADD FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id);

-- Many-to-Many
-- 1. publicationauthor
ALTER TABLE publicationauthor ADD FOREIGN KEY (publication_id) REFERENCES publication(publication_id);
ALTER TABLE publicationauthor ADD FOREIGN KEY (author_id) REFERENCES author(author_id);
ALTER TABLE publicationauthor ADD CONSTRAINT pub_author PRIMARY KEY (publication_id,author_id);

-- 2. publicationeditor
ALTER TABLE publicationeditor ADD FOREIGN KEY (publication_id) REFERENCES publication(publication_id);
ALTER TABLE publicationeditor ADD FOREIGN KEY (editor_id) REFERENCES author(author_id);
ALTER TABLE publicationeditor ADD CONSTRAINT pub_editor PRIMARY KEY (publication_id,editor_id);

-- 3. citation
ALTER TABLE citation ADD FOREIGN KEY (publication_id) REFERENCES publication(publication_id);
ALTER TABLE citation ADD FOREIGN KEY (citation_id) REFERENCES publication(publication_id);
ALTER TABLE citation ADD CONSTRAINT citation_pkey PRIMARY KEY (publication_id,citation_id);


-- Multivalued attributes:
ALTER TABLE publicationurl ADD FOREIGN KEY (publication_id) REFERENCES publication(publication_id);

ALTER TABLE publicationnote ADD FOREIGN KEY (publication_id) REFERENCES publication(publication_id);

ALTER TABLE publicationisbn ADD FOREIGN KEY (publication_id) REFERENCES publication(publication_id);
