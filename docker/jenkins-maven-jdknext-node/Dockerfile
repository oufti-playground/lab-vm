FROM openjdk:14-alpine

LABEL Maintainer="Damien DUPORTAL <damien.duportal@gmail.com"

ARG CUSTOM_JVM_OPTS="-XshowSettings:vm"
ENV DEFAULT_USER_HOME=/home/jenkins \
  DEFAULT_USER=jenkins \
  DEFAULT_USER_UID=1000 \
  LANG=C.UTF-8 \
  CUSTOM_JVM_OPTS=${CUSTOM_JVM_OPTS} \
  GIT_SSL_NO_VERIFY=true

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
  # Tune potential Maven executions
  && sed -i '/MAVEN_OPTS/d' /etc/mavenrc \
  && echo 'MAVEN_OPTS="'${CUSTOM_JVM_OPTS}'"' >> /etc/mavenrc

# Tune SSH Server for Jenkins Usage + sending logs on stdout
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
  && sed -i 's/#RSAAuthentication.*/RSAAuthentication yes/' /etc/ssh/sshd_config \
  && sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
  && sed -i 's/#SyslogFacility.*/SyslogFacility AUTH/' /etc/ssh/sshd_config \
  && sed -i 's/#LogLevel.*/LogLevel INFO/' /etc/ssh/sshd_config \
  && mkdir /var/run/sshd \
  && rm -f /var/log/auth.log \
  && ln -s /dev/stdout /var/log/auth.log

VOLUME "${DEFAULT_USER_HOME}" /tmp /run /var/run /etc/ssh
WORKDIR "${DEFAULT_USER_HOME}"

COPY jenkins-node-entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 22

HEALTHCHECK --start-period=3s --interval=10s --retries=3 --timeout=2s \
  CMD nc -z localhost 22

ENTRYPOINT ["/sbin/tini","-g","--","bash"]
CMD ["/usr/local/bin/entrypoint.sh"]
