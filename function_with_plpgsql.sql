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

-- asignment a variable from query
DO
$$
	DECLARE
		actor_name actor.first_name%type;
	BEGIN
		
		SELECT first_name
		FROM actor
		INTO actor_name;
		
		RAISE NOTICE '%', actor_name;
	END;
$$ LANGUAGE PLPGSQL;