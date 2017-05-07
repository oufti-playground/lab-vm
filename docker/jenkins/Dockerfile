FROM jenkins:2.46.2-alpine

COPY ./ref /usr/share/jenkins/ref

## Plugins Installation part
# Doc here: https://github.com/jenkinsci/docker#preinstalling-plugins
COPY plugins.txt /tmp/plugins.txt
RUN /usr/local/bin/install-plugins.sh $(cat /tmp/plugins.txt)
RUN curl  -L -o /usr/share/jenkins/ref/insecure_vagrant_key \
  https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant
