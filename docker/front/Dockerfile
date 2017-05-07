FROM nginx:stable-alpine

ENV TINI_VERSION=0.14.0 \
    TINI_SHA_256=6c41ec7d33e857d4779f14d9c74924cab0c7973485d2972419a3b7c7620ff5fd

# Use tini as subreaper in Docker container to adopt zombie processes
ADD "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64" /bin/tini
RUN chmod +x /bin/tini \
  && echo "$TINI_SHA_256  /bin/tini" | sha256sum -c -

COPY nginx-config/ /etc/nginx-templates
COPY ./docs /usr/share/www/html
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# ADD http://updates.jenkins-ci.org/latest/chucknorris.hpi /usr/share/nginx/html/chucknorris.hpi
# ADD https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub /usr/share/nginx/html/pub_key.txt

RUN chmod -R 755 /etc/nginx-templates \
    /etc/nginx \
    /usr/local/bin/entrypoint.sh \
    /usr/share/nginx/html

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
