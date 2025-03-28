#!/bin/bash
echo "Running wordpress.sh !"

DB_USER_PASS=$(cat $DB_USER_PASSWORD_FILE)
# echo "db_Name: ${DB_NAME}"
# echo "db_User: ${DB_USER}"
# echo "db_Pass: $(cat $DB_USER_PASSWORD_FILE)"
#
# echo "$(grep -oP 'name=\K.*' $WP_ADMIN_CREDENTIALS_FILE)"
# echo "$(grep -oP 'password=\K.*' $WP_ADMIN_CREDENTIALS_FILE)"
# echo "$(grep -oP 'email=\K.*' $WP_ADMIN_CREDENTIALS_FILE)"


echo "Waiting for mariadb to be started"
SLEEP_INTERVAL=5

attempts=1
while [ true ]; do
    if mysql -h mariadb -u"$DB_USER" -p"$DB_USER_PASS" -e "SELECT 1;" >/dev/null 2>&1; then
        echo "✅ MariaDB is up and running!"
        break
    fi
    echo "⌛ Attempt $attempt/$MAX_ATTEMPTS: MariaDB not ready yet. Waiting $SLEEP_INTERVAL seconds..."
    sleep $SLEEP_INTERVAL
    ((attempt++))
done

# Configure WordPress if wp-config.php doesn't exist
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Generating wordpress config"

    cd /var/www/html

    wp core config  --dbhost="$DB_HOSTNAME" \
                    --dbname="$DB_NAME" \
                    --dbuser="$DB_USER" \
                    --dbpass="$(cat $DB_USER_PASSWORD_FILE)" \
                    --allow-root

    echo "Installing wordpress"
    wp core install --url="$DOMAIN_NAME" \
                --title="$WP_TITLE" \
                --admin_user="$(grep -oP 'name=\K.*' $WP_ADMIN_CREDENTIALS_FILE)" \
                --admin_password="$(grep -oP 'password=\K.*' $WP_ADMIN_CREDENTIALS_FILE)" \
                --admin_email="$(grep -oP 'email=\K.*' $WP_ADMIN_CREDENTIALS_FILE)" \
                --allow-root

    echo "Creating a new user as author"
    wp user create "$(grep -oP 'name=\K.*' $WP_USER_CREDENTIALS_FILE)" \
                    "$(grep -oP 'email=\K.*' $WP_USER_CREDENTIALS_FILE)" \
                                        --user_pass="$(grep -oP 'password=\K.*' $WP_USER_CREDENTIALS_FILE)" \
                                                --role=author \
                                                --allow-root
fi

# creates the /run/php directory, which is used by PHP-FPM to store Unix domain sockets.
mkdir /run/php

# Start PHP-FPM
echo "Executing php to keep WP running"
php-fpm7.4 -F
