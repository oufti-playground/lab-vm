FROM openjdk:9-slim

LABEL Maintainer="Damien DUPORTAL <damien.duportal@gmail.com"

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG JENKINS_AGENT_HOME=/home/${user}
ENV JENKINS_AGENT_HOME ${JENKINS_AGENT_HOME}

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    git \
    maven \
    netcat \
    openjdk-8-jdk \
    openssh-server \
    tini \
  && rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${gid} ${group} \
    && useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}"

# Tune SSH Server for Jenkins Usage + sending logs on stdout
RUN sed -i /etc/ssh/sshd_config \
    -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
    -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
    -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
    -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
    -e 's/#LogLevel.*/LogLevel INFO/' \
  && mkdir /var/run/sshd \
  && rm -f /var/log/auth.log \
  && ln -s /dev/stdout /var/log/auth.log

VOLUME "${JENKINS_AGENT_HOME}" "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"

COPY jenkins-node-entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 22

HEALTHCHECK --start-period=3s --interval=10s --retries=3 --timeout=2s \
  CMD nc -z localhost 22

ENTRYPOINT ["/usr/bin/tini","-g","--","bash"]
CMD ["/usr/local/bin/entrypoint.sh"]
