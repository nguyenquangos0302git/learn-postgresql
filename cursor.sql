-- declare cursor
DO
$$

	DECLARE
		actor_record actor;
		cur_actor_rec CURSOR FOR SELECT * FROM actor;

	BEGIN
		OPEN cur_actor_rec;
		
		LOOP

			FETCH cur_actor_rec INTO actor_record;
			EXIT WHEN NOT FOUND;

			RAISE NOTICE '%', actor_record;

		END LOOP;

		CLOSE cur_actor_rec;
	END;

$$ LANGUAGE PLPGSQL;

-- open cursor unbounded
DO
$$
	DECLARE
	    cur_actor REFCURSOR; -- Unbound cursor declaration
	    actor_record actor;
	BEGIN
	    -- Open the cursor with a specific query
	    OPEN cur_actor FOR SELECT * FROM actor;
	
	    LOOP
	        FETCH cur_actor INTO actor_record; -- Fetch each row into the record
	        EXIT WHEN NOT FOUND; -- Exit loop when no more rows are found
	
	        -- RAISE NOTICE with individual fields from the record
	        RAISE NOTICE 'Actor ID: %, First Name: %, Last Name: %', 
	            actor_record.actor_id, 
	            actor_record.first_name, 
	            actor_record.last_name;
	    END LOOP;
	
	    CLOSE cur_actor; -- Close the cursor
	END;
$$ LANGUAGE plpgsql;

-- open cursor unbounded dynamic
DO
$$	
	DECLARE
		cur_actor REFCURSOR;		
		actor_rec actor;		
		query VARCHAR;		

	BEGIN
		query := 'SELECT * FROM actor WHERE actor_id = $1';

		OPEN cur_actor FOR EXECUTE query USING 1;
		
		LOOP
			FETCH cur_actor INTO actor_rec;
			EXIT WHEN NOT FOUND;
			RAISE NOTICE '%s', actor_rec;
		END LOOP;
		
		CLOSE cur_actor;

	END;

$$ LANGUAGE PLPGSQL;

-- open cursor bound
DO
$$

	DECLARE
		actor_rec actor;
		cur_actor CURSOR (id INTEGER) FOR SELECT * FROM actor WHERE actor_id = id;

	BEGIN
		OPEN cur_actor(1);
		LOOP
			FETCH cur_actor INTO actor_rec;
			EXIT WHEN NOT FOUND;
			RAISE NOTICE '%s', actor_rec;
		END LOOP;		
		CLOSE cur_actor;
	END;	

$$ LANGUAGE PLPGSQL;

-- fetch and move
DO
$$

	DECLARE
		actor_rec actor;
		cur_actor CURSOR FOR SELECT * FROM actor LIMIT 10;
	BEGIN
		OPEN cur_actor;
		
		MOVE FORWARD 5 IN cur_actor;

		LOOP
			
			FETCH cur_actor INTO actor_rec;
			EXIT WHEN NOT FOUND;
			RAISE NOTICE '%', actor_rec;	

		END LOOP;

		CLOSE cur_actor;
	END;

$$ LANGUAGE PLPGSQL;

-- currentof when update, delete
DO
$$

	DECLARE
				

	BEGIN
	END;

$$ LANGUAGE PLPGSQL;



