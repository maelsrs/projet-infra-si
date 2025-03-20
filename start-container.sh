#!/bin/bash
if [ -f /app/.env ]; then
  export $(grep -v '^#' /app/.env | xargs)
fi

mkdir -p /etc/letsencrypt/live/default
if [ ! -f /etc/letsencrypt/live/default/fullchain.pem ]; then
  openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
    -keyout /etc/letsencrypt/live/default/privkey.pem \
    -out /etc/letsencrypt/live/default/fullchain.pem \
    -subj "/CN=localhost"
fi

if [ ! -f /etc/letsencrypt/live/${MAIN_DOMAIN}/fullchain.pem ]; then
  mkdir -p /etc/letsencrypt/live/${MAIN_DOMAIN}
  openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
    -keyout /etc/letsencrypt/live/${MAIN_DOMAIN}/privkey.pem \
    -out /etc/letsencrypt/live/${MAIN_DOMAIN}/fullchain.pem \
    -subj "/CN=${MAIN_DOMAIN}"
fi

if [ ! -f /etc/letsencrypt/live/${WEKAN_SUBDOMAIN}/fullchain.pem ]; then
  mkdir -p /etc/letsencrypt/live/${WEKAN_SUBDOMAIN}
  openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
    -keyout /etc/letsencrypt/live/${WEKAN_SUBDOMAIN}/privkey.pem \
    -out /etc/letsencrypt/live/${WEKAN_SUBDOMAIN}/fullchain.pem \
    -subj "/CN=${WEKAN_SUBDOMAIN}"
fi

# Create Nginx config from template
envsubst '${MAIN_DOMAIN} ${WEKAN_SUBDOMAIN}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "Testing Nginx configuration..."
nginx -t

service nginx start || (echo "Nginx failed to start, check configuration" && cat /var/log/nginx/error.log)
cd /root/backend && ./main
