FROM docker/compose:1.24.1
LABEL Maintainer="Damien DUPORTAL - gmail.com"
RUN apk add --no-cache curl docker tini
COPY ./ /docker
WORKDIR /docker
ENTRYPOINT ["/sbin/tini","-g","--","/docker/launch.sh"]
