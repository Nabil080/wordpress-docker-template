FROM debian:bullseye

RUN apt-get update -y && apt-get upgrade -y

RUN apt-get install -y nginx openssl

# SSL Configuration
RUN mkdir -p /etc/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /etc/ssl/private/nginx.key -out /etc/ssl/certs/nginx.crt -subj "/C=FR/ST=IDF/L=Paris/O=42/CN=nbellila.42.fr";

# Copy config
COPY conf/nginx.conf /etc/nginx/sites-available/default

# Forward logs to Docker
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log


EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
