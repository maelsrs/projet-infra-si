FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y nginx curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# COPY nginx.conf /etc/nginx/nginx.conf
# COPY . /usr/share/nginx/html

EXPOSE 80

CMD service nginx start && bash
