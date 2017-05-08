FROM dduportal/jenkins-ssh-agent:alpine

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apk add --no-cache \
    curl \
    docker \
    git \
    maven \
    tini \
  && git clone https://github.com/sstephenson/bats.git /tmp/bats \
  && bash /tmp/bats/install.sh /usr/local \
  && rm -rf /tmp/bats \
  && chmod a+x /usr/local/bin/entrypoint.sh
