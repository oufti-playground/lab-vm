# Docker-agent image must be built before
# It will keep openjdk8 for running the slave.jar
# But will have jdk7 set by default
FROM jenkins-maven-jdk8-node

ENV JAVA_HOME=/usr/lib/jvm/java-1.7-openjdk

RUN apk add --no-cache openjdk7 \
  && unlink /usr/lib/jvm/default-jvm \
  && ln -s "${JAVA_HOME}" /usr/lib/jvm/default-jvm
