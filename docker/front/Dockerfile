FROM nginx:stable-alpine

RUN apk add --no-cache tini

COPY nginx-config/ /etc/nginx-templates
COPY ./docs /usr/share/www/html
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh

ENV EXTERNAL_PORT=80
EXPOSE ${EXTERNAL_PORT}
HEALTHCHECK --start-period=5s --interval=2s --retries=5 --timeout=5s \
  CMD wget localhost:${EXTERNAL_PORT} --spider

VOLUME ["/etc/nginx","/tmp","/var/cache/nginx","/var/run"]
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
