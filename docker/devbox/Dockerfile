# Be careful: not tag-versioned, behavior may change
FROM tsl0922/ttyd:alpine

ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG user_home=/home/${user}

# Prepare Dev Env
RUN apk add --update --no-cache \
    curl \
    ca-certificates \
    docker \
    docker-bash-completion \
    git \
    maven \
    openjdk8 \
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
  && sed -i 's/height:100%;/height:98%;/g' /index.html

USER ${user}

RUN git config --global user.email "${user}@localhost.local" \
  && git config --global user.name "${user}"

ENV PS1='jenkins@devbox> '

VOLUME ${user_home}
WORKDIR ${user_home}

CMD ["-I","/index.html","bash"]
