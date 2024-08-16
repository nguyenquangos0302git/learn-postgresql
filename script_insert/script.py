import psycopg2
from faker import Faker
import random
from datetime import datetime

# Database connection setup
conn = psycopg2.connect(
    dbname="postgres",
    user="postgres",
    password="123456",
    host="localhost",
    port="5432"
)

cur = conn.cursor()

fake = Faker()

def generate_actors(start_id, end_id):
    actors = []
    for i in range(start_id, end_id + 1):
        print("generate_actors", i)
        first_name = fake.first_name()
        last_name = fake.last_name()
        gender = random.choice(['M', 'F'])
        date_of_birth = fake.date_of_birth(minimum_age=18, maximum_age=90)
        add_date = datetime.now()
        update_date = datetime.now()
        actors.append((first_name, last_name, gender, date_of_birth, add_date, update_date))

    insert_query = """
    INSERT INTO actors (first_name, last_name, gender, date_of_birth, add_date, update_date)
    VALUES (%s, %s, %s, %s, %s, %s)
    """
    cur.executemany(insert_query, actors)
    conn.commit()

def generate_directors(start_id, end_id):
    directors = []
    for i in range(start_id, end_id + 1):
        print("generate_directors", i)
        first_name = fake.first_name()
        last_name = fake.last_name()
        date_of_birth = fake.date_of_birth(minimum_age=30, maximum_age=80)
        nationality = fake.country_code()
        add_date = datetime.now()
        update_date = datetime.now()
        directors.append((first_name, last_name, date_of_birth, nationality, add_date, update_date))
    
    insert_query = """
    INSERT INTO directors (first_name, last_name, date_of_birth, nationality, add_date, update_date)
    VALUES (%s, %s, %s, %s, %s, %s)
    """
    cur.executemany(insert_query, directors)
    conn.commit()

def generate_movies(start_id, end_id):
    movies = []
    for i in range(start_id, end_id + 1):
        print("generate_movies", i)
        movie_name = fake.catch_phrase()
        movie_length = random.randint(60, 180)
        movie_lang = fake.language_code()
        age_certificate = random.choice(['G', 'PG', 'PG-13', 'R', 'NC-17'])
        release_date = fake.date_this_century()
        director_id = random.randint(1, end_id)  # Adjust range based on actual director IDs
        movies.append((movie_name, movie_length, movie_lang, age_certificate, release_date, director_id))

    insert_query = """
    INSERT INTO movies (movie_name, movie_length, movie_lang, age_certificate, release_date, director_id)
    VALUES (%s, %s, %s, %s, %s, %s)
    """
    cur.executemany(insert_query, movies)
    conn.commit()

def generate_movies_revenues(start_id, end_id):
    revenues = []
    for i in range(start_id, end_id + 1):  # Assuming one revenue record per movie
        print("generate_movies_revenues", i)
        revenues_domestic = round(random.uniform(1000000, 99999999.99), 2)
        revenues_international = round(random.uniform(1000000, 99999999.99), 2)
        revenues.append((i, revenues_domestic, revenues_international))

    insert_query = """
    INSERT INTO movies_revenues (movie_id, revenues_domestic, revenues_international)
    VALUES (%s, %s, %s)
    """
    cur.executemany(insert_query, revenues)
    conn.commit()

def generate_movies_actors(start_id, end_id, min_actors, max_actors):
    movies_actors = []
    for i in range(start_id, end_id + 1):
        print("generate_movies_actors", i)
        num_actors = random.randint(min_actors, max_actors)  # Determine how many actors this movie will have
        actor_ids = random.sample(range(start_id, end_id + 1), num_actors)
        print("generate_movies_actors", actor_ids)
        for actor_id in actor_ids:
            movies_actors.append((i, actor_id))

    insert_query = """
    INSERT INTO movies_actors (movie_id, actor_id)
    VALUES (%s, %s)
    """
    cur.executemany(insert_query, movies_actors)
    conn.commit()

# Example usage:
start_id = 1
end_id = 20000
min_actors = 1
max_actors = 30
generate_actors(start_id, end_id)
generate_directors(start_id, end_id)
generate_movies(start_id, end_id)
generate_movies_revenues(start_id, end_id)
generate_movies_actors(start_id, end_id, min_actors, max_actors)

# Close the database connection
cur.close()
conn.close()
