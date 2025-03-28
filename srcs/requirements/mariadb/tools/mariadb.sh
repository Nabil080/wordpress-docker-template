#!/bin/bash
echo "Running mariadb.sh!"
# Increment volume
echo "+1" >> /var/lib/mysql/counter

service mariadb start

# Read secrets
DB_ROOT_PWD=$(cat $DB_ROOT_PASSWORD_FILE)
DB_USER_PWD=$(cat $DB_USER_PASSWORD_FILE)

# Debug logs
echo "Name: ${DB_NAME}"
echo "User: ${DB_USER}"
echo "Pass: ${DB_USER_PWD}"
echo "Root_Pass: ${DB_ROOT_PWD}"

# Generate SQL script
echo "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" > db1.sql
echo "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_USER_PWD}';" >> db1.sql
echo "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';" >> db1.sql
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';" >> db1.sql
echo "FLUSH PRIVILEGES;" >> db1.sql

# Execute SQL script
< db1.sql mysql -uroot -p$(cat $DB_ROOT_PASSWORD_FILE)

# Remove the script
rm db1.sql

# Now shutdown using the newly set root password
mysqladmin -u root -p"${DB_ROOT_PWD}" shutdown

# Restart MySQL in safe mode
exec mysqld_safe
