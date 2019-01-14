FROM jenkins/jenkins:2.138.4-alpine

# Used to provide Custom JVM to all elements (master and agents)
ARG CUSTOM_JVM_OPTS='-XshowSettings:vm -Djenkins.install.runSetupWizard=false'
ENV CUSTOM_JVM_OPTS=${CUSTOM_JVM_OPTS}

# Install Plugins
COPY plugins.txt /tmp/plugins.txt
RUN /usr/local/bin/install-plugins.sh $(cat /tmp/plugins.txt)

COPY ./ref /usr/share/jenkins/ref

RUN curl -L -o /usr/share/jenkins/ref/insecure_vagrant_key \
    https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant \
  && chmod 0600 /usr/share/jenkins/ref/insecure_vagrant_key

ENV JAVA_OPTS="${CUSTOM_JVM_OPTS}"

HEALTHCHECK --start-period=3s --interval=10s --retries=3 --timeout=2s \
  CMD curl -f http://localhost:8080/jenkins/login || exit 1
