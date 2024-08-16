-- Step 1: Create the `country` table
CREATE TABLE country (
    country_id SERIAL PRIMARY KEY,
    country VARCHAR(50) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Create the `city` table, which references `country`
CREATE TABLE city (
    city_id SERIAL PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    country_id INTEGER NOT NULL REFERENCES country(country_id),
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Step 3: Create the `address` table, which references `city`
CREATE TABLE address (
    address_id SERIAL PRIMARY KEY,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50),
    district VARCHAR(20) NOT NULL,
    city_id INTEGER NOT NULL REFERENCES city(city_id),
    postal_code VARCHAR(10),
    phone VARCHAR(20) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Step 4: Create the `actor` table
CREATE TABLE actor (
    actor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Step 5: Create the `language` table
CREATE TABLE language (
    language_id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Step 6: Create the `film` table, which references `language`
CREATE TABLE film (
    film_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    release_year INTEGER,
    language_id INTEGER NOT NULL REFERENCES language(language_id),
    rental_duration SMALLINT NOT NULL DEFAULT 3,
    rental_rate NUMERIC(4,2) NOT NULL DEFAULT 4.99,
    length SMALLINT,
    replacement_cost NUMERIC(5,2) NOT NULL DEFAULT 19.99,
    rating CHAR(5),
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Step 7: Create the `category` table
CREATE TABLE category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(25) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Step 8: Create the `store` table, which references `address`
CREATE TABLE store (
    store_id SERIAL PRIMARY KEY,
    manager_staff_id INTEGER NOT NULL,
    address_id INTEGER NOT NULL REFERENCES address(address_id),
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Step 9: Create the `staff` table, which references `store` and `address`
CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    address_id INTEGER NOT NULL REFERENCES address(address_id),
    email VARCHAR(50),
    store_id INTEGER NOT NULL REFERENCES store(store_id),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    username VARCHAR(16) NOT NULL,
    password VARCHAR(40),
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Step 10: Create the `customer` table, which references `store` and `address`
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL REFERENCES store(store_id),
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email VARCHAR(50),
    address_id INTEGER NOT NULL REFERENCES address(address_id),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    create_date DATE NOT NULL DEFAULT CURRENT_DATE,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Step 11: Create the `inventory` table, which references `film` and `store`
CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    film_id INTEGER NOT NULL REFERENCES film(film_id),
    store_id INTEGER NOT NULL REFERENCES store(store_id),
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Step 12: Create the `rental` table, which references `inventory`, `customer`, and `staff`
CREATE TABLE rental (
    rental_id SERIAL PRIMARY KEY,
    rental_date TIMESTAMP NOT NULL,
    inventory_id INTEGER NOT NULL REFERENCES inventory(inventory_id),
    customer_id INTEGER NOT NULL REFERENCES customer(customer_id),
    return_date TIMESTAMP,
    staff_id INTEGER NOT NULL REFERENCES staff(staff_id),
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Step 13: Create the `payment` table, which references `customer`, `staff`, and `rental`
CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customer(customer_id),
    staff_id INTEGER NOT NULL REFERENCES staff(staff_id),
    rental_id INTEGER NOT NULL REFERENCES rental(rental_id),
    amount NUMERIC(5,2) NOT NULL,
    payment_date TIMESTAMP NOT NULL
);

-- Step 14: Create the `film_actor` table, which references `actor` and `film`
CREATE TABLE film_actor (
    actor_id INTEGER NOT NULL REFERENCES actor(actor_id),
    film_id INTEGER NOT NULL REFERENCES film(film_id),
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (actor_id, film_id)
);

-- Step 15: Create the `film_category` table, which references `film` and `category`
CREATE TABLE film_category (
    film_id INTEGER NOT NULL REFERENCES film(film_id),
    category_id INTEGER NOT NULL REFERENCES category(category_id),
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (film_id, category_id)
);

-- Step 16: Create the `film_text` table
CREATE TABLE film_text (
    film_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    fulltext TSVECTOR
);

-- Step 17: Truncate the tables and reset identity columns
TRUNCATE TABLE
    actor,
    film,
    category,
    store,
    inventory,
    rental,
    payment,
    staff,
    customer,
    address,
    city,
    country,
    film_actor,
    film_category,
    film_text
RESTART IDENTITY CASCADE;
