FROM gitea/gitea:1.3

ARG first_user=dev
ARG source_repo_to_mirror

# We need tini to reap child processes
RUN apk add --no-cache tini

ENV EXTERNAL_URL=http://localhost:3000 \
    EXTERNAL_DOMAIN=localhost \
    FIRST_USER=${first_user} \
    SOURCE_REPO_TO_MIRROR=${source_repo_to_mirror}\
    SERVICE_CONFIG_FILE=/data/gitea/conf/app.ini

COPY ./setup-gitea.sh /app/setup-gitea.sh
COPY ./app.ini "${SERVICE_CONFIG_FILE}.tmpl"
COPY ./entrypoint.sh /usr/bin/entrypoint.sh


# Pre-configure the embeded Gitserver
RUN bash /app/setup-gitea.sh

# Custom SSH
EXPOSE 5022

VOLUME "/app/data"

# Custom Entrypoint
ENTRYPOINT ["/sbin/tini","-g","--","bash","/usr/bin/entrypoint.sh"]
