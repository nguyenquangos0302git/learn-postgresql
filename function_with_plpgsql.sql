-- pl/pgsql structure
DO
$$
<<first_block>>
DECLARE
	x INTEGER := 0;
BEGIN
	RAISE NOTICE '%', x;
END first_block;
$$ LANGUAGE PLPGSQL;

-- create funcition
CREATE OR REPLACE FUNCTION fn_api_get_max_payment()
RETURNS NUMERIC 
AS 
$$
	<<max_payment>>
	DECLARE
	BEGIN
		RETURN MAX(p.amount) FROM payment p;
	END max_payment;
$$ LANGUAGE PLPGSQL;

SELECT fn_api_get_max_payment();

-- declare variables
CREATE OR REPLACE FUNCTION fn_declare_variable()
RETURNS NUMERIC 
AS 
$$

	DECLARE
		counter INTEGER := 0;
	BEGIN
		RETURN counter;
	END;

$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fn_declare_variable_1()
RETURNS VOID
AS 
$$
	DECLARE
		counter INTEGER := 0;
		first_name VARCHAR;
		create_at TIME := clock_timestamp();
	BEGIN
		first_name := 'MARRY';
		RAISE NOTICE '%, %, %', counter, first_name, create_at;
		PERFORM pg_sleep(2);
		RAISE NOTICE '%, %, %', counter, first_name, create_at;
	END;
$$ LANGUAGE PLPGSQL;

SELECT fn_declare_variable_1();

DO
$$
	DECLARE
		actor_first_name actor.first_name%TYPE;		

	BEGIN

		SELECT first_name
		FROM actor
		INTO actor_first_name;

		RAISE NOTICE '%', actor_first_name;

	END;
$$ LANGUAGE PLPGSQL;

DO
$$

	<<first_block>>
	DECLARE
		counter_first INTEGER := 0;
	BEGIN

		RAISE NOTICE 'first block %', counter_first;
		
		<<second_block>>
		DECLARE
			counter_second INTEGER := 0;
		BEGIN
			counter_second = counter_first + 1;
			RAISE NOTICE 'second block %', 	first_block.counter_first;
			RAISE NOTICE 'second block %', counter_second;
	
		END second_block; 
	
	END first_block;

$$ LANGUAGE PLPGSQL;

-- declare parameter
CREATE OR REPLACE FUNCTION fn_declare_paramter(IN counter INTEGER, OUT result INTEGER)
AS 
$$
	DECLARE
	BEGIN
		SELECT counter + 1 INTO result;
	END;
$$ LANGUAGE PLPGSQL;

SELECT fn_declare_paramter(1);

-- returns table
CREATE OR REPLACE FUNCTION fn_return_table()
RETURNS TABLE(
	actor_first_name VARCHAR,
	actor_last_name VARCHAR
)
AS
$$
	DECLARE
	BEGIN
		RETURN QUERY
			SELECT first_name, last_name
			FROM actor;
	END;
$$ LANGUAGE PLPGSQL;

SELECT (fn_return_table()).*;

-- return setof
CREATE OR REPLACE FUNCTION fn_return_set_of()
RETURNS SETOF actor
AS 
$$
	DECLARE
	BEGIN

		RETURN QUERY
			SELECT *
			FROM actor;

	END;
$$ LANGUAGE PLPGSQL;

SELECT fn_return_set_of();

-- control structures
CREATE OR REPLACE FUNCTION fn_control_structures(IN id INTEGER, IN name VARCHAR)
RETURNS VOID
AS 
$$

	DECLARE
		rec record;
		query text;

	BEGIN
		query := 'SELECT * FROM actor WHERE actor_id = $1 AND first_name ilike $2';
		
		RAISE NOTICE '%', query;

		FOR rec IN EXECUTE query USING id, name
		LOOP
			RAISE NOTICE '%', rec;
		END LOOP;

		PERFORM * FROM actor WHERE actor_id = id;

		IF NOT FOUND THEN
			RAISE NOTICE 'NOT FOUND ACTOR';
		ELSE
			RAISE NOTICE 'FOUND';
		END IF;

	END;
	
$$ LANGUAGE PLPGSQL;

SELECT fn_control_structures(1, '%Jenna%');


-- return next
CREATE OR REPLACE FUNCTION fn_return_query()
RETURNS TABLE(
	actor_first_name VARCHAR,
	actor_last_name VARCHAR
)
AS
$$

	DECLARE
	BEGIN

		RETURN QUERY 
			SELECT first_name, last_name
			FROM actor;

	END;

$$ LANGUAGE PLPGSQL;

SELECT (fn_return_query()).*;

CREATE OR REPLACE FUNCTION fn_return_next_to()
RETURNS TABLE (
	actor_first_name VARCHAR,
	actor_last_name VARCHAR
)
AS
$$

	DECLARE
		rec record;
		query text;

	BEGIN
		query := 'SELECT * FROM actor';		

		FOR rec IN EXECUTE query
		LOOP
			actor_first_name := rec.first_name;
			actor_last_name := rec.last_name;
			RETURN NEXT;
		END LOOP;		

	END;

$$ LANGUAGE PLPGSQL;

SELECT (fn_return_next_to()).*;





















