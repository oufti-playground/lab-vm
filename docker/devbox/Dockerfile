# Be careful: not tag-versioned, behavior may change
FROM tsl0922/ttyd:alpine

# Prepare Dev Env
RUN apk add --update --no-cache \
    curl \
    ca-certificates \
    docker-bash-completion \
    git \
    maven \
    openjdk8 \
  && curl -L -o /tmp/docker.tgz \
    https://get.docker.com/builds/Linux/x86_64/docker-17.03.0-ce.tgz \
  && tar xzf /tmp/docker.tgz -C /tmp \
  && mv /tmp/docker/* /usr/bin/ \
  && chmod a+x /usr/bin/docker* \
  && rm -f /tmp/docker.tgz
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
VOLUME /workspace
WORKDIR /workspace
