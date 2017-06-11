FROM dduportal/jenkins-ssh-agent:docker-alpine

RUN apk add --no-cache maven \
  && git clone https://github.com/sstephenson/bats.git /tmp/bats \
  && bash /tmp/bats/install.sh /usr/local \
  && rm -rf /tmp/bats

ARG CUSTOM_JVM_OPTS=-XshowSettings:vm
RUN sed -i '/MAVEN_OPTS/d' /etc/mavenrc \
  && echo 'MAVEN_OPTS="'${CUSTOM_JVM_OPTS}'"' >> /etc/mavenrc
