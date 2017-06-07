FROM nginx:stable-alpine

ARG REMOTE_SLIDES_DIST_ZIP="http://dduportal.github.io/presentations/bxl-jam-201706/dist.zip"

RUN wget "${REMOTE_SLIDES_DIST_ZIP}" -O /tmp/dist.zip \
  && unzip /tmp/dist.zip -d /usr/share/nginx/html \
  && rm -f /tmp/dist.zip \
  && cp "$(find /usr/share/nginx/html -type f -name 'slides*.html')" /usr/share/nginx/html/index.html \
  && chown -R nginx:nginx /usr/share/nginx/html
