FROM jenkins:2.46.2-alpine

## Plugins Installation part
# Doc here: https://github.com/jenkinsci/docker#preinstalling-plugins
COPY plugins.txt /tmp/plugins.txt
RUN /usr/local/bin/install-plugins.sh $(cat /tmp/plugins.txt)

# Installing Vagrant Insecure Key for SSH agent demo
RUN curl -L -o /usr/share/jenkins/ref/insecure_vagrant_key \
    https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant

## Auto-Configure Jenkins at stratup with Groovy Hooks
# Doc here: https://wiki.jenkins-ci.org/display/JENKINS/Groovy+Hook+Script
COPY ./ref /usr/share/jenkins/ref
