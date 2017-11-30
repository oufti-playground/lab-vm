#!/bin/bash

set -eu -o pipefail

# Set path context
TARGET_PATH="$(dirname ${0})/../docker"
ABSOLUTE_TARGET_PATH="$(cd ${TARGET_PATH} && pwd)"

# Fetch variable from environment or use default values
JENKINS_URL=${JENKINS_URL:-http://localhost:10000/jenkins/}
JENKINS_PRIVATE_URL=${JENKINS_PRIVATE_URL:-http://localhost:8080/jenkins}
JENKINS_ADMIN_USER=${JENKINS_ADMIN_USER:-butler}
JENKINS_ADMIN_PASSWORD=${JENKINS_ADMIN_PASSWORD:-butler}

cd ${ABSOLUTE_TARGET_PATH} || \
  (echo "Error going to ${ABSOLUTE_TARGET_PATH}" && exit 1)


## Start Jenkins in current state
docker-compose up -d

## Wait for Jenkins Startup
sleep 2
curl -s -S -L -o /dev/null --fail --retry 30 --retry-delay 5 \
    "${JENKINS_URL}"

## Jenkins is started: We update installed plugins

# We use the jenkins container to be sure a compliant openjdk is installed
JENKINS_CLI_PATH=/tmp/jenkins-cli.jar
PLUGIN_TXT_LIST_FILE="$(mktemp)"
docker-compose exec jenkins curl -L -s -S -o "${JENKINS_CLI_PATH}" \
  "${JENKINS_PRIVATE_URL}/jnlpJars/jenkins-cli.jar"

# We fetch the list of plugins
docker-compose exec jenkins java -jar ${JENKINS_CLI_PATH} \
  -s ${JENKINS_PRIVATE_URL} list-plugins \
  | grep ')[[:cntrl:]]*$' \
  | awk '{ print $1 }' \
  > ${PLUGIN_TXT_LIST_FILE}
echo "Plugin list written in ${PLUGIN_TXT_LIST_FILE}"

# We request a plugin install to latest version for each
if [ -n "$(cat ${PLUGIN_TXT_LIST_FILE})" ]; then
  docker-compose exec jenkins java -jar "${JENKINS_CLI_PATH}" \
    -s "${JENKINS_PRIVATE_URL}" install-plugin -restart --username "${JENKINS_ADMIN_USER}" --password "${JENKINS_ADMIN_PASSWORD}" \
    $(cat ${PLUGIN_TXT_LIST_FILE} | sed ':a;N;$!ba;s/\n/ /g')
fi
sleep 5
# Restart Jenkins
# docker-compose restart jenkins

# Wait for Jenkins coming back online
curl -s -S -L -o /dev/null --fail --retry 30 --retry-delay 5 \
    "${JENKINS_URL}"

# Fetch Jenkins plugins list
echo "== Jenkins Restarted and back online. Writing the plugin list to plugins.txt"
sleep 1
curl -s -v -S -u "${JENKINS_ADMIN_USER}:${JENKINS_ADMIN_PASSWORD}" -L \
    "${JENKINS_URL}/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" \
  | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g' \
  | sed 's/ /:/' \
  | sort \
  | uniq > "${ABSOLUTE_TARGET_PATH}/jenkins/plugins.txt"

# Git
echo "== Finished. Here is the git diff"
git diff
