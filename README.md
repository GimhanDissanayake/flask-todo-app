# flask-todo-app
A simple Flask-based To-Do application with a PostgreSQL database backend.

# Setup

## start postgres container locally using docker
docker run --name dev-postgres -p 5432:5432 -e POSTGRES_PASSWORD=dbsecret123 -d postgres:alpine


```bash
# connect to database
psql -h localhost -d <db-name> -U <username> -W
-W - forces psql to ask for the user password before connecting to the database
```

```
# create database for todo app
CREATE DATABASE todo_db;
# create user
CREATE USER todo_user WITH PASSWORD 'password';
ALTER ROLE todo_user SET client_encoding TO 'utf8';
ALTER ROLE todo_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE todo_user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE todo_db TO todo_user;

-- Switch to the database
\c todo_db;

-- Grant all privileges on the public schema to the user
GRANT USAGE, CREATE ON SCHEMA public TO todo_user;

-- Ensure future tables and sequences are accessible
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL ON TABLES TO todo_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL ON SEQUENCES TO todo_user;
```

```
# other commands (Ref: https://hasura.io/blog/top-psql-commands-and-flags-you-need-to-know-postgresql)
\l - list databases
\c <db-name> - Switch to another database - \c
\dt - List database tables
\d <table-name> - Describe a table 
\d+ <table-name>
\dn - List all schemas
\du - List users
\du <username> - Retrieve a specific user
\df - List all functions
\dv - List all views
\o <file-name> - Save query results to a file
...run the psql commands...
\o - stop the process and output the results to the terminal again
\i <file-name> - Run commands from a file
\q - Quit psql
```

## Run the Flask application:
python app.py

Visit http://127.0.0.1:5000/ in your browser.
