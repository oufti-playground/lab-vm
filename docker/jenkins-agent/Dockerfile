FROM dduportal/jenkins-ssh-agent:docker-alpine

RUN apk add --no-cache maven \
  && git clone https://github.com/sstephenson/bats.git /tmp/bats \
  && bash /tmp/bats/install.sh /usr/local \
  && rm -rf /tmp/bats
