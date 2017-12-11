FROM jenkins/jenkins:2.89.1-alpine

# Used to provide Custom JVM to all elements (master and agents)
ARG CUSTOM_JVM_OPTS=-XshowSettings:vm
ENV CUSTOM_JVM_OPTS=${CUSTOM_JVM_OPTS}

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false ${CUSTOM_JVM_OPTS}"

# Install Plugins
COPY plugins.txt /tmp/plugins.txt
RUN /usr/local/bin/install-plugins.sh $(cat /tmp/plugins.txt)

COPY ./ref /usr/share/jenkins/ref

RUN curl -L -o /usr/share/jenkins/ref/insecure_vagrant_key \
  https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant
