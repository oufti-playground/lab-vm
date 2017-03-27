FROM docker:17.03.0-ce-dind

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG JENKINS_AGENT_HOME=/home/${user}

ENV JENKINS_AGENT_HOME ${JENKINS_AGENT_HOME}

RUN addgroup -g ${gid} ${group} \
    && adduser \
        -h "${JENKINS_AGENT_HOME}" \
        -u "${uid}" \
        -G "${group}" \
        -s /bin/bash \
        -D "${user}" \
    && echo "${user}:${user}" | chpasswd

# setup SSH server
RUN apk add --update --no-cache \
    bash \
    git \
    openssh \
    openjdk8
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
RUN sed -i 's/#RSAAuthentication.*/RSAAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN sed -i 's/#SyslogFacility.*/SyslogFacility AUTH/' /etc/ssh/sshd_config
RUN sed -i 's/#LogLevel.*/LogLevel INFO/' /etc/ssh/sshd_config

RUN mkdir /var/run/sshd
RUN rm -f /var/log/auth.log && ln -s /dev/stdout /var/log/auth.log

VOLUME "${JENKINS_AGENT_HOME}" "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"

COPY entrypoint.sh /usr/local/bin/

EXPOSE 22

ENTRYPOINT ["entrypoint.sh"]
