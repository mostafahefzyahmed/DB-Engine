#!/bin/bash

source database_operations.sh
source table_operations.sh

# Set relative path to the database directory
DATABASE_DIR="./databases"

# Ensure the databases directory exists
if [ ! -d "$DATABASE_DIR" ]; then
    mkdir "$DATABASE_DIR"
fi

while true; do
    echo -e "\nMain Menu:"
    echo "1. Create Database"
    echo "2. List Databases"
    echo "3. Connect To Database"
    echo "4. Drop Database"
    echo "5. Exit"
    
    read -p "Enter your choice: " choice

    case $choice in
        1) read -p "Enter database name: " db_name; create_database "$db_name";;
        2) list_databases ;;
        3) read -p "Enter database name to connect: " db_name; connect_to_database "$db_name";;
        4) read -p "Enter database name to drop: " db_name; drop_database "$db_name";;
        5) exit ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
done

