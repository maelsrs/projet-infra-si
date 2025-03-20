#!/bin/bash

if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

mkdir -p ssl/certs ssl/www

mkdir -p ssl/certs/live/default
openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout ssl/certs/live/default/privkey.pem \
  -out ssl/certs/live/default/fullchain.pem \
  -subj "/CN=localhost" \
  -addext "subjectAltName = DNS:localhost"

docker-compose up -d web

echo "Waiting for web container to start..."
sleep 10

docker-compose exec web service nginx stop

docker-compose run --rm certbot certonly --webroot \
  --webroot-path=/var/www/certbot \
  --email admin@${MAIN_DOMAIN} \
  --agree-tos --no-eff-email \
  -d ${MAIN_DOMAIN} -d www.${MAIN_DOMAIN}

docker-compose run --rm certbot certonly --webroot \
  --webroot-path=/var/www/certbot \
  --email admin@${MAIN_DOMAIN} \
  --agree-tos --no-eff-email \
  -d ${WEKAN_SUBDOMAIN}

docker-compose down
docker-compose up -d

echo "- https://${MAIN_DOMAIN}"
echo "- https://www.${MAIN_DOMAIN}"
echo "- https://${WEKAN_SUBDOMAIN}"
