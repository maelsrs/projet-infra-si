FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y nginx curl golang && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html /root/images /root/backend /data/attachments

COPY frontend/ /var/www/html/
COPY backend/ /root/backend/
COPY nginx.conf /etc/nginx/nginx.conf

RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    mkdir /var/www/images && \
    chown -R www-data:www-data /var/www/images && \
    chmod -R 755 /var/www/images && \
    chown -R www-data:www-data /data/attachments && \
    chmod -R 755 /data/attachments

WORKDIR /root/backend
RUN go build -o main .

EXPOSE 80 3000

CMD service nginx start && ./main
