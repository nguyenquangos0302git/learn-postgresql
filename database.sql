-- actors
CREATE TABLE actors (
	actor_id SERIAL PRIMARY KEY,
	first_name VARCHAR(150),
	last_name VARCHAR(150) NOT NULL,
	gender CHAR(1),
	date_of_birth DATE,
	add_date DATE,
	update_date DATE
);

-- directors
CREATE TABLE directors (
	director_id SERIAL PRIMARY KEY,
	first_name VARCHAR(150),
	last_name VARCHAR(150) NOT NULL,
	date_of_birth DATE,
	nationality VARCHAR(20),
	add_date DATE,
	update_date DATE
);

-- movies
CREATE TABLE movies (
	movie_id SERIAL PRIMARY KEY,
	movie_name VARCHAR(100) NOT NULL,
	movie_length INT,
	movie_lang VARCHAR(20),
	age_certificate VARCHAR(10),
	release_date DATE,
	director_id INT REFERENCES directors (director_id)
);


-- movies_revenues
CREATE TABLE movies_revenues (
	revenue_id SERIAL PRIMARY KEY,
	movie_id INT REFERENCES movies (movie_id),
	revenues_domestic NUMERIC (10,2),
	revenues_international NUMERIC (10,2)
);


-- movies_actors
CREATE TABLE movies_actors (
	movie_id INT REFERENCES movies (movie_id),
	actor_id INT REFERENCES actors (actor_id),
	PRIMARY KEY (movie_id, actor_id)
);


DO $$
DECLARE 
    i INTEGER;
BEGIN
    FOR i IN 1..1000000 LOOP
        INSERT INTO actors (first_name, last_name, gender, date_of_birth, add_date, update_date)
        VALUES (
            (SELECT substring(md5(random()::text), 1, 10)),  -- Random first name
            (SELECT substring(md5(random()::text), 1, 15)),  -- Random last name
            (SELECT CASE WHEN random() < 0.5 THEN 'M' ELSE 'F' END),  -- Random gender
            (SELECT date '1950-01-01' + (random() * (date '2000-01-01' - date '1950-01-01'))::int),  -- Random DOB
            CURRENT_DATE,
            CURRENT_DATE
        );
    END LOOP;
END $$;

DO $$
DECLARE 
    i INTEGER;
BEGIN
    FOR i IN 1..1000000 LOOP
        INSERT INTO directors (first_name, last_name, date_of_birth, nationality, add_date, update_date)
        VALUES (
            (SELECT substring(md5(random()::text), 1, 10)),  -- Random first name
            (SELECT substring(md5(random()::text), 1, 15)),  -- Random last name
            (SELECT date '1940-01-01' + (random() * (date '1990-01-01' - date '1940-01-01'))::int),  -- Random DOB
            (SELECT substring(md5(random()::text), 1, 2)),  -- Random nationality code
            CURRENT_DATE,
            CURRENT_DATE
        );
    END LOOP;
END $$;

DO $$
DECLARE 
    i INTEGER;
BEGIN
    FOR i IN 1..1000000 LOOP
        INSERT INTO movies (movie_name, movie_length, movie_lang, age_certificate, release_date, director_id)
        VALUES (
            (SELECT substring(md5(random()::text), 1, 20)),  -- Random movie name
            (SELECT 60 + floor(random() * 120)::int),  -- Random movie length between 60 and 180 minutes
            (SELECT substring(md5(random()::text), 1, 2)),  -- Random movie language code
            (SELECT CASE WHEN random() < 0.25 THEN 'G' 
                         WHEN random() < 0.5 THEN 'PG' 
                         WHEN random() < 0.75 THEN 'PG-13' 
                         ELSE 'R' END),  -- Random age certificate
            (SELECT date '1980-01-01' + (random() * (date '2023-01-01' - date '1980-01-01'))::int),  -- Random release date
            (SELECT floor(random() * 1000000 + 1)::int)  -- Random director_id between 1 and 1 million
        );
    END LOOP;
END $$;

DO $$
DECLARE 
    i INTEGER;
BEGIN
    FOR i IN 1..1000000 LOOP
        INSERT INTO movies_revenues (movie_id, revenues_domestic, revenues_international)
        VALUES (
            i,  -- Assuming movie_id matches the loop index
            (SELECT round((random() * 99999999)::numeric, 2)),  -- Random domestic revenue between 0 and 99,999,999.99
            (SELECT round((random() * 99999999)::numeric, 2))  -- Random international revenue between 0 and 99,999,999.99
        );
    END LOOP;
END $$;

DO $$
DECLARE 
    i INTEGER;
    actor_id INTEGER;
    assigned_actors integer[];
BEGIN
    FOR i IN 1..1000000 LOOP
        assigned_actors := ARRAY[]::integer[];
        FOR j IN 1..10 LOOP  -- Assuming each movie has 10 actors
            LOOP
                actor_id := (SELECT floor(random() * 1000000 + 1)::int);
                IF actor_id = ANY(assigned_actors) THEN
                    CONTINUE;
                ELSE
                    assigned_actors := array_append(assigned_actors, actor_id);
                    EXIT;
                END IF;
            END LOOP;
            INSERT INTO movies_actors (movie_id, actor_id)
            VALUES (i, actor_id);
        END LOOP;
    END LOOP;
END $$;