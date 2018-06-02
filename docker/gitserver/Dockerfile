FROM gitea/gitea:1.3.3

ARG first_user
ARG source_repo_to_mirror

ENV EXTERNAL_URL=http://localhost:3000 \
    EXTERNAL_DOMAIN=localhost \
    SERVICE_CONFIG_FILE=/data/gitea/conf/app.ini \
    LOAD_SSH_KEY_FROM_JENKINS=false \
    FIRST_USER=${first_user} \
    SOURCE_REPO_TO_MIRROR=${source_repo_to_mirror}

COPY ./setup-gitea.sh /app/setup-gitea.sh
COPY ./app.ini "${SERVICE_CONFIG_FILE}.tmpl"
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ./set-key-from-jenkins-to-gitea.sh /usr/local/bin/set-key-from-jenkins-to-gitea.sh

# We need tini to reap child processes
RUN apk add --no-cache jq tini \
  && bash /app/setup-gitea.sh start-gitserver

VOLUME "/app/data"

# Custom SSH
EXPOSE 5022

HEALTHCHECK --start-period=10s --interval=10s --retries=3 --timeout=2s \
  CMD wget localhost:3000 --spider

HEALTHCHECK --start-period=10s --interval=10s --retries=3 --timeout=2s \
  CMD nc -z localhost 5022

# Custom Entrypoint
ENTRYPOINT ["/sbin/tini","-g","--"]
CMD ["bash","/usr/local/bin/entrypoint.sh"]
