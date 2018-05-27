FROM gitea/gitea@sha256:776fea5667a1067cc57b8098f69264194ad1b34864e50be9ef0b51e189ef7c11

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

# Custom Entrypoint
ENTRYPOINT ["/sbin/tini","-g","--"]
CMD ["bash","/usr/local/bin/entrypoint.sh"]
