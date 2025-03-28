#!/bin/bash
echo "Running wordpress.sh !"

echo "db_Name: ${DB_NAME}"
echo "db_User: ${DB_USER}"
echo "db_Pass: $(cat $DB_USER_PASSWORD_FILE)"


# Configure WordPress if wp-config.php doesn't exist
if [ ! -f /var/www/wordpress/wp-config.php ]; then
    echo "Generating wordpress config"
    wp core config  --dbhost="$DB_HOSTNAME" \
                    --dbname="$DB_NAME" \
                    --dbuser="$DB_USER" \
                    --dbpass="$(cat $DB_USER_PASSWORD_FILE)" \
                    --allow-root

    echo "Installing wordpress"
    wp core install --url="$DOMAIN_NAME" \
                --title="$WP_TITLE" \
                --admin_user="$WP_ADMIN_USER" \
                --admin_password="$WP_ADMIN_PASSWORD" \
                --admin_email="$WP_ADMIN_EMAIL" \
                --allow-root

    echo "Creating a new user as author"
	wp user create "$WP_USER" "$WP_USER_EMAIL"  --user_pass="$WP_USER_PASSWORD" \
                                                --role="$WP_USER_ROLE" \
                                                --allow-root
fi

# Start PHP-FPM
echo "Executing php to keep WP running"
php-fpm7.4 -F
