FROM docker:stable-dind

ARG CUSTOM_JVM_OPTS=-XshowSettings:vm

ENV JENKINS_USER_HOME=/home/jenkins \
  JENKINS_USER=jenkins \
  JENKINS_USER_UID=1000 \
  LANG=C.UTF-8 \
  JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk \
  PATH=${PATH}:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin \
  DOCKER_IMAGE_CACHE_DIR=/docker-cache \
  START_DOCKER="true" \
  DOCKER_STORAGE_DRIVER="overlay2" \
  DOCKER_OPTS="--insecure-registry=docker-registry:5000 --bip=192.168.0.1/24"

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
    tini

# Creat default user and groups
# Default Group and Default User are the same, with same ID
RUN addgroup -g "${JENKINS_USER_UID}" "${JENKINS_USER}" \
    && adduser -h "${JENKINS_USER_HOME}" -u "${JENKINS_USER_UID}" \
      -G "${JENKINS_USER}" -s /bin/bash -D "${JENKINS_USER}" \
  && echo "${JENKINS_USER}:${JENKINS_USER}" | chpasswd

# Docker Engine tuning + adapt PATH to Jenkins
RUN addgroup docker \
  && addgroup "${JENKINS_USER}" docker \
  && addgroup "${JENKINS_USER}" dockremap \
  && ln -s /usr/local/bin/docker* /usr/bin/

### Install Docker-compose
RUN pip install --no-cache-dir "docker-compose"

# Tune SSH
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
  && sed -i 's/#RSAAuthentication.*/RSAAuthentication yes/' /etc/ssh/sshd_config \
  && sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
  && sed -i 's/#SyslogFacility.*/SyslogFacility AUTH/' /etc/ssh/sshd_config \
  && sed -i 's/#LogLevel.*/LogLevel INFO/' /etc/ssh/sshd_config \
  && mkdir /var/run/sshd \
  && rm -f /var/log/auth.log \
  && ln -s /dev/stdout /var/log/auth.log

## Tune potential Maven executions
RUN sed -i '/MAVEN_OPTS/d' /etc/mavenrc \
  && echo 'MAVEN_OPTS="'${CUSTOM_JVM_OPTS}'"' >> /etc/mavenrc

COPY daemon.json /etc/docker/daemon.json
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

VOLUME ${JENKINS_USER_HOME} /docker-cache /var/run /run

EXPOSE 22

ENTRYPOINT ["/sbin/tini","-g","--","bash"]
CMD ["/usr/local/bin/entrypoint.sh"]
