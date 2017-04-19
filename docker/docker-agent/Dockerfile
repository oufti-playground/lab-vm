FROM dduportal/jenkins-ssh-agent:alpine

RUN apk add --update --no-cache curl git
RUN curl -L -o /tmp/docker.tgz \
    https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz \
  && tar xzf /tmp/docker.tgz -C /tmp \
  && mv /tmp/docker/* /usr/bin/ \
  && chmod a+x /usr/bin/docker* \
  && rm -f /tmp/docker.tgz

RUN git clone https://github.com/sstephenson/bats.git /tmp/bats \
  && bash /tmp/bats/install.sh /usr/local \
  && rm -rf /tmp/bats

COPY entrypoint.sh /usr/local/bin/

ENTRYPOINT ["bash","entrypoint.sh"]
