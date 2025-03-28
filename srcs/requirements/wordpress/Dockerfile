FROM debian:bullseye
WORKDIR /app

RUN apt-get update -y && apt-get upgrade -y

# Install packages
RUN apt-get install -y php7.3 php-fpm php-mysql curl

# go to /var/www/html and empty it
RUN mkdir -p /var/www/html && cd /var/www/html

# Install Wordpress--CLI and make `wp` executable
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar 
RUN mv wp-cli.phar /usr/local/bin/wp

# Download wordpress using wordpress CLI
RUN wp core download --allow-root --path=/var/www/html

# Copy PHP configuration file
RUN mkdir -p /etc/php/7.3/fpm/pool.d/
COPY conf/www.conf /etc/php/7.3/fpm/pool.d/www.conf

# Maybe expose a port

# Copy and run script
COPY ./tools/wordpress.sh /app
RUN chmod +x ./wordpress.sh

CMD ["./wordpress.sh"]
