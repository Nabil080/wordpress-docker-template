FROM debian:bullseye
WORKDIR /app

RUN apt-get update -y && apt-get upgrade -y

RUN apt-get install mariadb-server -y

COPY . /app

RUN chmod +x ./tools/mariadb.sh

CMD ["./tools/mariadb.sh"]
