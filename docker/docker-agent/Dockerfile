FROM dduportal/jenkins-ssh-agent:alpine

RUN apk add --update --no-cache curl docker git

RUN git clone https://github.com/sstephenson/bats.git /tmp/bats \
  && bash /tmp/bats/install.sh /usr/local \
  && rm -rf /tmp/bats
