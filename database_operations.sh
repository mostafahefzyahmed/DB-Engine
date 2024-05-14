#!/bin/bash

# Functions

# Create Database
create_database() {
    local db_name="$1"

    if [[ ! "$db_name" =~ ^[a-zA-Z]+$ ]]; then
        echo "Invalid database name. Use only letters."
        return
    fi

    if [ -d "$DATABASE_DIR/$db_name" ]; then
        echo "Database '$db_name' already exists."
    else
        mkdir "$DATABASE_DIR/$db_name"
        echo "Database '$db_name' created successfully."
    fi
}

# List Databases
list_databases() {
    echo "Databases:"
    for database in "$DATABASE_DIR"/*; do
        if [ -d "$database" ]; then
            echo "${database##*/}"
        fi
    done
}

# Connect to Database
connect_to_database() {
    local db_name="$1"
    
    if [[ ! "$db_name" =~ ^[a-zA-Z]+$ ]]; then
        echo "Invalid database name. Use only letters."
        return
    fi

    if [ -d "$DATABASE_DIR/$db_name" ]; then
        echo "Connected to '$db_name'."
        database_menu "$db_name"
    else
        echo "Database '$db_name' does not exist."
    fi
}

# Drop Database
drop_database() {
    local db_name="$1"

    if [[ ! "$db_name" =~ ^[a-zA-Z]+$ ]]; then
        echo "Invalid database name. Use only letters."
        return
    fi

    if [ -d "$DATABASE_DIR/$db_name" ]; then
        rm -rf "$DATABASE_DIR/$db_name"
        echo "Database '$db_name' dropped successfully."
    else
        echo "Database '$db_name' does not exist."
    fi
}

