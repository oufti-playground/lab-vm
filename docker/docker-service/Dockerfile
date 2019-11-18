FROM alpine:3.10
LABEL Maintainer="Damien DUPORTAL<damien.duportal@gmail.com>"

RUN apk add --no-cache socat

HEALTHCHECK --start-period=3s --interval=10s --retries=3 --timeout=2s \
  CMD nc -z localhost:2375

ENTRYPOINT ["/usr/bin/socat"]
