#!/bin/bash
set -e

# Vérifier la présence du fichier .env
if [ ! -f .env ]; then
    echo ".env file is missing. Stopping the container."
    exit 1
fi

# Function to wait for the database
wait_for_database() {
    echo "Waiting for database to be ready..."
    while ! pg_isready -q -h $DATABASE_HOST -p $DATABASE_PORT -U $DATABASE_USER; do
        echo "Database is unavailable - sleeping"
        sleep 2
    done
    echo "Database is up and running!"
}

# Check if we need to wait for the database
if [ "$WAIT_FOR_DB" = true ]; then
    wait_for_database
fi

# Check if the database exists and create it if it does not
if [ "$CREATE_DB" = true ]; then
    echo "Checking if the database exists..."
    if ! psql -h "$DATABASE_HOST" -U "$DATABASE_USER" -d "$DATABASE_NAME" -c '\l' | grep -q "$DATABASE_NAME"; then
        echo "Database does not exist. Creating database..."
        createdb -h "$DATABASE_HOST" -U "$DATABASE_USER" "$DATABASE_NAME"
    else
        echo "Database $DATABASE_NAME already exists."
    fi
fi

# Run database migrations if needed
if [ "$RUN_MIGRATIONS" = true ]; then
    echo "Running database migrations..."
    mix ecto.migrate
fi

echo "Initialization completed. Starting the application..."

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
