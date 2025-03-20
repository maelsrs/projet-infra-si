#!/bin/bash
if [ -f /app/.env ]; then
  export $(grep -v '^#' /app/.env | xargs)
fi

envsubst '${MAIN_DOMAIN} ${WEKAN_SUBDOMAIN}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

service nginx start
cd /root/backend && ./main
