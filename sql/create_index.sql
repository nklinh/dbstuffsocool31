\timing on
CREATE INDEX pub_year_index ON Publication (year);

CREATE INDEX pub_year_key_index ON Publication(year, key);

CREATE INDEX pub_key_index ON Publication(key);