-- function with sql (query language function)
CREATE OR REPLACE FUNCTION fn_sum(p1 INTEGER, p2 INTEGER) 
RETURNS INTEGER
AS
'
	SELECT p1 + p2;
' LANGUAGE SQL;

SELECT fn_sum(1, 2);

-- dollar quoting
CREATE OR REPLACE FUNCTION fn_sum_with_dollar_quoting_1(p1 INTEGER, p2 INTEGER)
RETURNS INTEGER
AS 
$$
	SELECT p1 + p2;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION fn_sum_with_dollar_quoting_2(p1 INTEGER, p2 INTEGER)
RETURNS INTEGER
AS 
$body$
	SELECT p1 + p2;
$body$ LANGUAGE SQL;

SELECT fn_sum_with_dollar_quoting_1(1, 2);
SELECT fn_sum_with_dollar_quoting_2(1, 2);

-- returns void (no value)
CREATE OR REPLACE FUNCTION fn_insert_new_actor()
RETURNS void
AS
$$
	UPDATE actors
	SET last_name = 'Nelson'
	WHERE actor_id = 20000;
$$ LANGUAGE SQL;

SELECT fn_insert_new_actor();

-- return a single value
SELECT MIN(revenues_domestic)
FROM movies_revenues

CREATE OR REPLACE FUNCTION fn_get_min_revenuse_domestic()
RETURNS NUMERIC
AS
$$
	SELECT MIN(revenues_domestic)
	FROM movies_revenues;
$$ LANGUAGE SQL;

SELECT fn_get_min_revenuse_domestic();

-- paramter
CREATE OR REPLACE FUNCTION fn_sum_two_value(p1 INTEGER DEFAULT 1, p2 INTEGER DEFAULT 1)
RETURNS INTEGER
AS
$$
	SELECT p1 + p2;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION fn_get_total_director_by_national(nation varchar)
RETURNS bigint
AS 
$$
	SELECT COUNT(nationality)
	FROM directors d
	WHERE d.nationality = nation
	GROUP BY d.nationality;
$$ LANGUAGE SQL;

SELECT fn_sum_two_value(2, 3);
SELECT fn_get_total_director_by_national('US');

-- return/paramter a composite
DROP FUNCTION fn_get_actors(actors);

CREATE OR REPLACE FUNCTION fn_get_actors(actors_row actors)
RETURNS actors
AS 
$$
	SELECT ROW(actors_row.*);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION fn_get_actors_2()
RETURNS actors
AS 
$$
	SELECT *
	FROM actors;
$$ LANGUAGE SQL;

SELECT fn_get_actors(a.*) FROM actors a LIMIT 2;
SELECT fn_get_actors_2();

-- return multiple rows
CREATE OR REPLACE FUNCTION fn_return_multiple_rows()
RETURNS SETOF actors
AS 
$$
	SELECT *
	FROM actors;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION fn_return_multiple_row_2(actor_row actors)
RETURNS SETOF actors
AS 
$$
	SELECT *
	FROM actors;
$$ LANGUAGE SQL;

SELECT fn_return_multiple_rows();

-- as a table source
CREATE OR REPLACE FUNCTION fn_as_a_table_source(id INTEGER)
RETURNS actors
AS
$$
	SELECT *
	FROM actors
	WHERE actor_id = id
$$ LANGUAGE SQL;

SELECT * FROM fn_as_a_table_source(1);

CREATE OR REPLACE FUNCTION fn_as_a_table_source_1(gender_actor bpchar)
RETURNS SETOF actors
AS 
$$
	SELECT *
	FROM actors
	WHERE gender = gender_actor
$$ LANGUAGE SQL;

SELECT * FROM fn_as_a_table_source_1('M');

-- return a table
CREATE OR REPLACE FUNCTION fn_return_a_table()
RETURNS TABLE(
	id int,
	first_name varchar,
	last_name varchar
)
AS
$$
	SELECT actor_id, first_name, last_name
	FROM actors;
$$ LANGUAGE SQL;

SELECT * FROM fn_return_a_table();

-- function overloading
CREATE OR REPLACE FUNCTION fn_overloading(a INT, b REAL)
RETURNS INTEGER
AS
$$
	SELECT a;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION fn_overloading(a SMALLINT, b DOUBLE PRECISION)
RETURNS INTEGER
AS
$$
	SELECT b;
$$ LANGUAGE SQL;

SELECT fn_overloading(5, 5.5);