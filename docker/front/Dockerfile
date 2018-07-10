FROM nginx:stable-alpine

RUN apk add --no-cache tini

COPY nginx-config/ /etc/nginx-templates
COPY ./docs /usr/share/www/html
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh

HEALTHCHECK --start-period=3s --interval=10s --retries=3 --timeout=2s \
  CMD wget localhost:80 --spider

VOLUME ["/etc/nginx","/tmp","/var/cache/nginx","/var/run"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
