FROM docker:dind

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

ENV JENKINS_AGENT_HOME=/home/${user} \
  JAVA_HOME=/usr/lib/jvm/default-jvm

RUN apk add --update --no-cache \
  bash \
  curl \
  ca-certificates \
  git \
  openjdk8 \
  openssh \
  tar \
  && addgroup -g ${gid} ${group} \
  && adduser -h "${JENKINS_AGENT_HOME}" -u "${uid}" -G "${group}" -D -s /bin/bash "${user}" \
  && passwd -u jenkins \
  && sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
  && sed -i 's/#RSAAuthentication.*/RSAAuthentication yes/' /etc/ssh/sshd_config \
  && sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config \
  && sed -i 's/#SyslogFacility.*/SyslogFacility AUTH/' /etc/ssh/sshd_config \
  && sed -i 's/#LogLevel.*/LogLevel INFO/' /etc/ssh/sshd_config \
  && sed -i 's/#PermitUserEnvironment.*/PermitUserEnvironment yes/' /etc/ssh/sshd_config \
  && sed -i 's/#UseDNS.*/UseDNS no/' /etc/ssh/sshd_config \
  && addgroup docker \
  && addgroup jenkins docker \
  && mkdir /var/run/sshd

VOLUME "${JENKINS_AGENT_HOME}" "/tmp"
WORKDIR "${JENKINS_AGENT_HOME}"

COPY setup-sshd /usr/local/bin/setup-sshd

EXPOSE 22

ENTRYPOINT ["setup-sshd"]
