FROM debian:bullseye
WORKDIR /app

RUN apt-get update -y && apt-get upgrade -y

RUN apt-get install mariadb-server -y

COPY ./tools/mariadb.sh /app

RUN chmod +x ./mariadb.sh

CMD ["./mariadb.sh"]
