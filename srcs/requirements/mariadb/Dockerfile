FROM debian:bullseye
WORKDIR /app

RUN apt-get update -y && apt-get upgrade -y

RUN apt-get install mariadb-server -y

EXPOSE 3306

# copy conf
COPY conf/50-server.cnf	/etc/mysql/mariadb.conf.d/50-server.cnf

# copy and exec script
COPY ./tools/mariadb.sh /app
RUN chmod +x ./mariadb.sh
CMD ["./mariadb.sh"]
