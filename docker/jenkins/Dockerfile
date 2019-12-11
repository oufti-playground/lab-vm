FROM jenkins/jenkins:2.190.3-alpine

# Used to provide Custom JVM to all elements (master and agents)
ARG CUSTOM_JVM_OPTS='-XshowSettings:vm -Djenkins.install.runSetupWizard=false -XX:+UseG1GC'
ENV CUSTOM_JVM_OPTS=${CUSTOM_JVM_OPTS} \
  CASC_JENKINS_CONFIG=/usr/share/jenkins/jenkins.yaml \
  JAVA_OPTS="${CUSTOM_JVM_OPTS}"

# Install Plugins
COPY plugins.txt /tmp/plugins.txt
RUN /usr/local/bin/install-plugins.sh $(cat /tmp/plugins.txt)

# CasC
COPY jenkins.yaml /usr/share/jenkins/jenkins.yaml

HEALTHCHECK --start-period=3s --interval=10s --retries=3 --timeout=2s \
  CMD curl -f http://localhost:8080/jenkins/login || exit 1
