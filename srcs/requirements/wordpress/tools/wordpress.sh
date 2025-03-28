#!/bin/bash
echo "Running wordpress.sh !"

echo "db_Name: ${DB_NAME}"
echo "db_User: ${DB_USER}"
echo "db_Pass: $(cat $DB_USER_PASSWORD_FILE)"

wp config create --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$(cat $DB_USER_PASSWORD_FILE) --dbhost=$DB_HOST --path=/var/www/html --allow-root
