-- create user
CREATE USER todo_user WITH PASSWORD '${todoPassword}';
ALTER ROLE todo_user SET client_encoding TO 'utf8';
ALTER ROLE todo_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE todo_user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE todo_db TO todo_user;