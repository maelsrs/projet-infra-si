FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y nginx curl golang gettext-base && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html /root/images /root/backend /data/attachments /app

COPY .env /app/.env
COPY frontend/ /var/www/html/
COPY backend/ /root/backend/
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY start-container.sh /app/start.sh

RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    mkdir /var/www/images && \
    chown -R www-data:www-data /var/www/images && \
    chmod -R 755 /var/www/images && \
    chown -R www-data:www-data /data/attachments && \
    chmod -R 755 /data/attachments && \
    chmod +x /app/start.sh

WORKDIR /root/backend
RUN go build -o main .

EXPOSE 80 3000

CMD ["/app/start.sh"]
