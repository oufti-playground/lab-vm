FROM alpine:3.6

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG user_home=/home/${user}

# Prepare Dev Env
RUN apk add --update --no-cache \
    bash \
    curl \
    ca-certificates \
    docker \
    docker-bash-completion \
    git \
    maven \
    nginx \
    openjdk8 \
    supervisor \
    ttyd \
  && addgroup -g ${gid} ${group} \
  && adduser \
    -h "${user_home}" \
    -u "${uid}" \
    -G "${group}" \
    -s /bin/bash \
    -D "${user}" \
  && echo "${user}:${user}" | chpasswd

# Tune the TTYD terminal Windows to avoid loosing last line when scrolling
RUN curl -L -o /index.html \
    https://raw.githubusercontent.com/tsl0922/ttyd/master/src/index.html \
  && sed -i 's/height:100%;/height:98%;/g' /index.html \
  && chown -R nginx:nginx /var/log/nginx

ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk \
  DOCKER_HOST=unix:///var/run/docker.sock \
  TTYD_USER=${user} \
  TTYD_UID=${uid} \
  TTYD_GID=${gid} \
  TTYD_USER_HOME=${user_home} \
  PS1='\u@devbox [\w]> '

USER ${user}

RUN git config --global user.email "${user}@localhost.local" \
  && git config --global user.name "${user}"

USER root
COPY supervisord.conf /etc/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

VOLUME ${user_home} /tmp /run /var/log/nginx /var/tmp/nginx

ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-c","/etc/supervisord.conf"]
