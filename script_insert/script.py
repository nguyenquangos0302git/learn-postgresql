import psycopg2
from faker import Faker
import random

def insert_records(start_id, num_records):
    # Establish a connection to the PostgreSQL database
    conn = psycopg2.connect(
        dbname="postgres",
        user="postgres",
        password="123456",
        host="localhost",
        port="5432"
    )
    cur = conn.cursor()

    # Initialize Faker for generating random data
    faker = Faker()

    # Insert records into the country table
    for i in range(start_id, start_id + num_records):
        country = faker.country()[:50]  # Truncate to 50 characters
        cur.execute("INSERT INTO country (country) VALUES (%s)", (country,))
        print(f"Inserting record {i} into country")

    # Insert records into the city table
    cur.execute("SELECT country_id FROM country")
    country_ids = [row[0] for row in cur.fetchall()]
    for i in range(start_id, start_id + num_records):
        city = faker.city()[:50]  # Truncate to 50 characters
        country_id = random.choice(country_ids)
        cur.execute("INSERT INTO city (city, country_id) VALUES (%s, %s)", (city, country_id))
        print(f"Inserting record {i} into city")

    # Insert records into the address table
    cur.execute("SELECT city_id FROM city")
    city_ids = [row[0] for row in cur.fetchall()]
    for i in range(start_id, start_id + num_records):
        address = faker.street_address()[:50]  # Truncate to 50 characters
        address2 = faker.street_address()[:50]  # Truncate to 50 characters
        district = faker.state()[:20]  # Truncate to 20 characters
        postal_code = faker.postcode()[:10]  # Truncate to 10 characters
        phone = faker.phone_number()[:20]  # Truncate to 20 characters
        city_id = random.choice(city_ids)
        cur.execute("INSERT INTO address (address, address2, district, city_id, postal_code, phone) VALUES (%s, %s, %s, %s, %s, %s)", 
                    (address, address2, district, city_id, postal_code, phone))
        print(f"Inserting record {i} into address")

    # Insert records into the actor table
    for i in range(start_id, start_id + num_records):
        first_name = faker.first_name()[:45]  # Truncate to 45 characters
        last_name = faker.last_name()[:45]  # Truncate to 45 characters
        cur.execute("INSERT INTO actor (first_name, last_name) VALUES (%s, %s)", (first_name, last_name))
        print(f"Inserting record {i} into actor")

    # Insert records into the language table
    for i in range(start_id, start_id + num_records):
        language = faker.language_name()[:20]  # Truncate to 20 characters
        cur.execute("INSERT INTO language (name) VALUES (%s)", (language,))
        print(f"Inserting record {i} into language")

    # Insert records into the film table
    cur.execute("SELECT language_id FROM language")
    language_ids = [row[0] for row in cur.fetchall()]
    for i in range(start_id, start_id + num_records):
        title = faker.sentence(nb_words=3)[:255]  # Truncate to 255 characters
        description = faker.text()[:255]  # Truncate to 255 characters
        release_year = random.randint(1980, 2024)
        language_id = random.choice(language_ids)
        rental_duration = random.randint(1, 10)
        rental_rate = round(random.uniform(1.99, 9.99), 2)
        length = random.randint(60, 180)
        replacement_cost = round(random.uniform(10.99, 39.99), 2)
        rating = random.choice(['G', 'PG', 'PG-13', 'R', 'NC-17'])[:5]  # Truncate to 5 characters
        cur.execute("""INSERT INTO film (title, description, release_year, language_id, rental_duration, rental_rate, length, 
                                          replacement_cost, rating) 
                       VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)""",
                    (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating))
        print(f"Inserting record {i} into film")

    # Insert records into the category table
    for i in range(start_id, start_id + num_records):
        name = faker.word()[:25]  # Truncate to 25 characters
        cur.execute("INSERT INTO category (name) VALUES (%s)", (name,))
        print(f"Inserting record {i} into category")

    # Insert records into the store table
    cur.execute("SELECT address_id FROM address")
    address_ids = [row[0] for row in cur.fetchall()]
    for i in range(start_id, start_id + num_records):
        manager_staff_id = random.randint(1, num_records)
        address_id = random.choice(address_ids)
        cur.execute("INSERT INTO store (manager_staff_id, address_id) VALUES (%s, %s)", (manager_staff_id, address_id))
        print(f"Inserting record {i} into store")

    # Insert records into the staff table
    for i in range(start_id, start_id + num_records):
        first_name = faker.first_name()[:45]  # Truncate to 45 characters
        last_name = faker.last_name()[:45]  # Truncate to 45 characters
        address_id = random.choice(address_ids)
        email = faker.email()[:50]  # Truncate to 50 characters
        store_id = random.randint(1, num_records)
        username = faker.user_name()[:16]  # Truncate to 16 characters
        password = faker.password()[:40]  # Truncate to 40 characters
        active = random.choice([True, False])  # Randomly choose True or False for active
        cur.execute("""INSERT INTO staff (first_name, last_name, address_id, email, store_id, active, username, password) 
                       VALUES (%s, %s, %s, %s, %s, %s, %s, %s)""",
                    (first_name, last_name, address_id, email, store_id, active, username, password))
        print(f"Inserting record {i} into staff")

    # Insert records into the customer table
    for i in range(start_id, start_id + num_records):
        store_id = random.choice(address_ids)
        first_name = faker.first_name()[:45]  # Truncate to 45 characters
        last_name = faker.last_name()[:45]  # Truncate to 45 characters
        email = faker.email()[:50]  # Truncate to 50 characters
        address_id = random.choice(address_ids)
        active = random.choice([True, False])  # Randomly choose True or False for active
        cur.execute("""INSERT INTO customer (store_id, first_name, last_name, email, address_id, active) 
                       VALUES (%s, %s, %s, %s, %s, %s)""",
                    (store_id, first_name, last_name, email, address_id, active))
        print(f"Inserting record {i} into customer")

    # Insert records into the inventory table
    cur.execute("SELECT film_id FROM film")
    film_ids = [row[0] for row in cur.fetchall()]
    for i in range(start_id, start_id + num_records):
        film_id = random.choice(film_ids)
        store_id = random.randint(1, num_records)
        cur.execute("INSERT INTO inventory (film_id, store_id) VALUES (%s, %s)", (film_id, store_id))
        print(f"Inserting record {i} into inventory")

    # Insert records into the rental table
    cur.execute("SELECT inventory_id FROM inventory")
    inventory_ids = [row[0] for row in cur.fetchall()]
    cur.execute("SELECT customer_id FROM customer")
    customer_ids = [row[0] for row in cur.fetchall()]
    cur.execute("SELECT staff_id FROM staff")
    staff_ids = [row[0] for row in cur.fetchall()]
    for i in range(start_id, start_id + num_records):
        rental_date = faker.date_time_this_year()
        inventory_id = random.choice(inventory_ids)
        customer_id = random.choice(customer_ids)
        return_date = faker.date_time_this_year()
        staff_id = random.choice(staff_ids)
        cur.execute("""INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id) 
                       VALUES (%s, %s, %s, %s, %s)""",
                    (rental_date, inventory_id, customer_id, return_date, staff_id))
        print(f"Inserting record {i} into rental")

    # Insert records into the payment table
    for i in range(start_id, start_id + num_records):
        customer_id = random.choice(customer_ids)
        staff_id = random.choice(staff_ids)
        rental_id = random.randint(1, num_records)
        amount = round(random.uniform(1.99, 9.99), 2)
        payment_date = faker.date_time_this_year()
        cur.execute("""INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date) 
                       VALUES (%s, %s, %s, %s, %s)""",
                    (customer_id, staff_id, rental_id, amount, payment_date))
        print(f"Inserting record {i} INTO payment")

    # Insert records into the film_actor table
    cur.execute("SELECT actor_id FROM actor")
    actor_ids = [row[0] for row in cur.fetchall()]
    for i in range(start_id, start_id + num_records):
        actor_id = random.choice(actor_ids)
        film_id = random.choice(film_ids)
        cur.execute("INSERT INTO film_actor (actor_id, film_id) VALUES (%s, %s)", (actor_id, film_id))
        print(f"Inserting record {i} into film_actor")

    # Insert records into the film_category table
    existing_combinations = set()
    for i in range(start_id, start_id + num_records):
        film_id = random.randint(1, 5000)  # Assuming film_id range from 1 to 5000
        category_id = random.randint(1, 5000)  # Assuming category_id range from 1 to 5000

        # Ensure the combination is unique
        while (film_id, category_id) in existing_combinations:
            film_id = random.randint(1, 5000)
            category_id = random.randint(1, 5000)

        existing_combinations.add((film_id, category_id))

        cur.execute("INSERT INTO film_category (film_id, category_id) VALUES (%s, %s)", (film_id, category_id))
        print(f"Inserting record {i} into film_category")

    # Insert records into the film_text table
    for i in range(start_id, start_id + num_records):
        title = faker.sentence(nb_words=3)[:255]  # Truncate to 255 characters
        description = faker.text()[:255]  # Truncate to 255 characters
        cur.execute("""
            INSERT INTO film_text (title, description, fulltext) 
            VALUES (%s, %s, to_tsvector(%s))
        """, (title, description, description))
        print(f"Inserting record {i} into film_text")

    # Commit the transaction
    conn.commit()

    # Close the cursor and connection
    cur.close()
    conn.close()

# Example usage
insert_records(start_id=1, num_records=5000)
