#!/bin/bash
set -e

# Check if required environment variables are set
if [ -z "$POSTGRES_HOST" ] || [ -z "$POSTGRES_PORT" ] || [ -z "$POSTGRES_ADMIN_USER" ] || \
   [ -z "$POSTGRES_ADMIN_PASSWORD" ] || [ -z "$APP_USER" ] || [ -z "$APP_PASSWORD" ] || \
   [ -z "$APP_DB" ]; then
    echo "Error: Required environment variables are not set"
    echo "Please set: POSTGRES_HOST, POSTGRES_PORT, POSTGRES_ADMIN_USER, POSTGRES_ADMIN_PASSWORD,"
    echo "           APP_USER, APP_PASSWORD, APP_DB"
    exit 1
fi

# Export PGPASSWORD for psql to use
export PGPASSWORD="$POSTGRES_ADMIN_PASSWORD"

# Function to check if a user exists
user_exists() {
    psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_ADMIN_USER" -d postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$APP_USER'" | grep -q 1
    return $?
}

# Function to check if a database exists
database_exists() {
    psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_ADMIN_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$APP_DB'" | grep -q 1
    return $?
}

# Create user if it doesn't exist
if ! user_exists; then
    echo "Creating user $APP_USER..."
    psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_ADMIN_USER" -d postgres << EOF
    CREATE USER $APP_USER WITH PASSWORD '$APP_PASSWORD';
EOF
    echo "User $APP_USER created successfully"
else
    echo "User $APP_USER already exists"
fi

# Create database if it doesn't exist
if ! database_exists; then
    echo "Creating database $APP_DB..."
    psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_ADMIN_USER" -d postgres << EOF
    CREATE DATABASE $APP_DB;
    GRANT ALL PRIVILEGES ON DATABASE $APP_DB TO $APP_USER;
EOF
    echo "Database $APP_DB created successfully"
else
    echo "Database $APP_DB already exists"
fi

# Grant privileges
echo "Creating schema and granting privileges..."
psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_ADMIN_USER" -d "$APP_DB" << EOF
-- Switch to the database
\c todo_db;
-- Grant all privileges on the public schema to the user
GRANT USAGE, CREATE ON SCHEMA public TO todo_user;
-- Ensure future tables and sequences are accessible
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL ON TABLES TO todo_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL ON SEQUENCES TO todo_user;
EOF

echo "Database setup completed successfully"

# Unset PGPASSWORD for security
unset PGPASSWORD