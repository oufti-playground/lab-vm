FROM nginx:stable-alpine

COPY ./nginx-config/conf.d /etc/nginx/conf.d
COPY ./nginx-config/locations /etc/nginx/locations
COPY ./nginx-config/proxy.conf /etc/nginx/proxy.conf
COPY ./docs /usr/share/www/html
