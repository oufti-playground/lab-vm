FROM jenkins:2.46.3-alpine

COPY plugins.txt /tmp/plugins.txt
ENV CURL_CONNECTION_TIMEOUT=60 \
  CURL_RETRY=10 \
  CURL_RETRY_DELAY=10
RUN /usr/local/bin/install-plugins.sh $(cat /tmp/plugins.txt)
COPY ./ref /usr/share/jenkins/ref
RUN curl -L -o /usr/share/jenkins/ref/insecure_vagrant_key \
  https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant
