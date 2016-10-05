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

