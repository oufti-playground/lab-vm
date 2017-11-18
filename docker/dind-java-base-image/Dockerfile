FROM docker:stable-dind

ARG CUSTOM_JVM_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XshowSettings:vm"

ENV DEFAULT_USER_HOME=/home/jenkins \
  DEFAULT_USER=jenkins \
  DEFAULT_USER_UID=1000 \
  LANG=C.UTF-8 \
  JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk \
  PATH=${PATH}:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin \
  DOCKER_IMAGE_CACHE_DIR=/docker-cache \
  START_DOCKER="true" \
  DOCKER_STORAGE_DRIVER="overlay2" \
  CUSTOM_JVM_OPTS=${CUSTOM_JVM_OPTS}

# Install packages
RUN apk add --no-cache \
    bash \
    bats \
    coreutils \
    curl \
    git \
    maven \
    openjdk8 \
    openssh \
    perl \
    py-pip \
    ttf-dejavu \
    unzip \
    tar \
    tini \
  # Create default user and groups
  # Default Group and Default User are the same, with same ID
  && addgroup -g "${DEFAULT_USER_UID}" "${DEFAULT_USER}" \
    && adduser -h "${DEFAULT_USER_HOME}" -u "${DEFAULT_USER_UID}" \
      -G "${DEFAULT_USER}" -s /bin/bash -D "${DEFAULT_USER}" \
  && echo "${DEFAULT_USER}:${DEFAULT_USER}" | chpasswd \
  # Add default user to docker groups + tune PATH
  && addgroup docker \
  && addgroup "${DEFAULT_USER}" docker \
  && addgroup "${DEFAULT_USER}" dockremap \
  && ln -s /usr/local/bin/docker* /usr/bin/ \
  # Install latest Docker-compose
  && pip install --no-cache-dir "docker-compose" \
  # Tune potential Maven executions
  && sed -i '/MAVEN_OPTS/d' /etc/mavenrc \
  && echo 'MAVEN_OPTS="'${CUSTOM_JVM_OPTS}'"' >> /etc/mavenrc

COPY daemon.json /etc/docker/daemon.json
COPY dind-entrypoint.sh /usr/local/bin/dind-entrypoint.sh

VOLUME ${DEFAULT_USER_HOME} /docker-cache /var/run /run /etc/docker

ENTRYPOINT ["/sbin/tini","-g","--","bash"]
CMD ["/usr/local/bin/dind-entrypoint.sh"]
