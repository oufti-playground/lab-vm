FROM nginx:stable-alpine

ARG REMOTE_SLIDES_DIST_ZIP="http://dduportal.github.io/presentations/devfest-lille-2017/dist.zip"

RUN wget "${REMOTE_SLIDES_DIST_ZIP}" -O /tmp/dist.zip \
  && unzip /tmp/dist.zip -d /usr/share/nginx/html -o \
  && rm -f /tmp/dist.zip \
  && chown -R nginx:nginx /usr/share/nginx/html
