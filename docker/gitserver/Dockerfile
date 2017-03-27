FROM gitea/gitea:1.0.1

ENV EXTERNAL_URL=http://localhost:3000

ARG FIRST_USER=dev
ARG FIRST_REPO_NAME=gitea
ARG SOURCE_REPO_TO_MIRROR=https://github.com/go-gitea/gitea

COPY ./setup-gitea.sh /app/setup-gitea.sh
COPY ./app.ini /etc/templates/app.ini
COPY ./run /etc/s6/gitea/run
RUN chmod a+x /etc/s6/gitea/run \
    && bash /app/setup-gitea.sh
VOLUME "/app/data"
