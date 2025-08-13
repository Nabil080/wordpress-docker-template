### Wordpress-template

## About

This is a starter template for a wordpress project using docker-compose to manage multiple containers using volumes and network.

## Quick start

- Create a .env based on the template inside the srcs/ folder
- Use the makefile to build/start the containers
```bash
make # will build and launch
``` 
- Go to `https://localhost:443` or `https://nabil.fr` (customizable)

## Details

Each container executes a shell script upon start, here is the sequence of the containers in order :

# Mariadb (database)
- Starts the mariadb service
- Create the database using the environment variables (only on first launch)
- Starts the database in safe mode

# Wordpress
- Tries to connect to the database (1 attempt every 3sec, 10 attempts max)
- Configures wordpress based on the environment variable (only on first launch)
- Starts the wordpress processor (php-fpm)

# Nginx
- Starts an HTTPS server based on nginx.conf which uses the environment and the wordpress volume

## Default values and customization

# .env
You should change the credentials inside the .env and keep them secret

# volumes
This setup uses volumes that are binding files on your machine to the containers : One for the database and one for the website.

By default they are located at `$HOME/data`
If you want to change this path you have to update `DATA_PATH` in the Makefile and the volumes in docker-compose.yml

# port
This setup uses a docker network, keeping everything inside the containers. The only exposed port is 443 for nginx.
To change it, update the value in docker-compose.yml and nginx.conf

# domain name
A hostname is added to /etc/host during the `make` execution, allowing you to use a domain instead of an ip address.

To customize it, change the value in the Makefile and in nginx.conf

## Other

```bash
make all # setup + build + launch
make setup # will prepare necessary folders
make build # only build
make up # only launch
make down # stop the containers
make clean # removes things related to docker (images, networks...)
make fclean # also removes the local file (wordpress volumes)
make re # fclean + all
```
