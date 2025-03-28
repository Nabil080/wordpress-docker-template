#!/bin/bash
echo "=== Starting wordpress.sh ==="

# Read secrets
DB_USER_PASS=$(cat "$DB_USER_PASSWORD_FILE")
WP_ADMIN_NAME=$(grep -oP 'name=\K.*' "$WP_ADMIN_CREDENTIALS_FILE")
WP_ADMIN_PASS=$(grep -oP 'password=\K.*' "$WP_ADMIN_CREDENTIALS_FILE")
WP_ADMIN_EMAIL=$(grep -oP 'email=\K.*' "$WP_ADMIN_CREDENTIALS_FILE")
WP_USER_NAME=$(grep -oP 'name=\K.*' "$WP_USER_CREDENTIALS_FILE")
WP_USER_EMAIL=$(grep -oP 'email=\K.*' "$WP_USER_CREDENTIALS_FILE")
WP_USER_PASS=$(grep -oP 'password=\K.*' "$WP_USER_CREDENTIALS_FILE")

# Debug
echo "[DEBUG] Configuration:"
echo "DB_HOSTNAME: $DB_HOSTNAME"
echo "DB_NAME: $DB_NAME"
echo "DB_USER: $DB_USER"
echo "DOMAIN_NAME: $DOMAIN_NAME"
echo "WP_TITLE: $WP_TITLE"
echo "WP_ADMIN: $WP_ADMIN_NAME (email: $WP_ADMIN_EMAIL)"
echo "WP_USER: $WP_USER_NAME (email: $WP_USER_EMAIL)"

# Wait for mariadb
MAX_ATTEMPTS=10
SLEEP_INTERVAL=3
attempt=1

echo "Waiting for MariaDB to become available (max ${MAX_ATTEMPTS} attempts)..."
while [ $attempt -le $MAX_ATTEMPTS ]; do
    if mysql -h"$DB_HOSTNAME" -u"$DB_USER" -p"$DB_USER_PASS" -e "SELECT 1;" >/dev/null 2>&1; then
        echo "✅ MariaDB connection successful (attempt $attempt/$MAX_ATTEMPTS)"
        break
    fi
    
    echo "⏳ Attempt $attempt/$MAX_ATTEMPTS failed - retrying in ${SLEEP_INTERVAL}s..."
    sleep $SLEEP_INTERVAL
    ((attempt++))
    
    if [ $attempt -gt $MAX_ATTEMPTS ]; then
        echo "❌ ERROR: Failed to connect to MariaDB after $MAX_ATTEMPTS attempts"
        exit 1
    fi
done

# Configure WordPress if wp-config.php doesn't exist
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Generating WordPress configuration"
    cd /var/www/html || exit 1

    wp core config \
        --dbhost="$DB_HOSTNAME" \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_USER_PASS" \
        --allow-root
    
    echo "Installing WordPress core"
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_NAME" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
    
    echo "Creating author user"
    wp user create \
        "$WP_USER_NAME" \
        "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASS" \
        --role=author \
        --allow-root
    
    echo "WordPress setup completed successfully"
else
    echo "WordPress configuration already exists - skipping setup"
fi

# creates the /run/php directory, which is used by PHP-FPM to store Unix domain sockets.
mkdir -p /run/php
exec php-fpm7.4 -F
