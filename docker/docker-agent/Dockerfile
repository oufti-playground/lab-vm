FROM dduportal/jenkins-ssh-agent:alpine

RUN apk add --update --no-cache curl git
RUN curl -L -o /tmp/docker.tgz \
    https://get.docker.com/builds/Linux/x86_64/docker-17.03.0-ce.tgz \
  && tar xzf /tmp/docker.tgz -C /tmp \
  && mv /tmp/docker/* /usr/bin/ \
  && chmod a+x /usr/bin/docker* \
  && rm -f /tmp/docker.tgz

COPY entrypoint.sh /usr/local/bin/

ENTRYPOINT ["bash","entrypoint.sh"]
