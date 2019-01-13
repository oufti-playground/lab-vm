#!/bin/bash

set -eu -o pipefail

# Set path context
TARGET_PATH="$(dirname "${0}")/../docker"
ABSOLUTE_TARGET_PATH="$(cd "${TARGET_PATH}" && pwd -P)"

# Fetch variable from environment or use default values
JENKINS_PRIVATE_URL=${JENKINS_PRIVATE_URL:-http://localhost:8080/jenkins}
JENKINS_ADMIN_USER=${JENKINS_ADMIN_USER:-butler}
JENKINS_ADMIN_PASSWORD=${JENKINS_ADMIN_PASSWORD:-butler}

pushd "${ABSOLUTE_TARGET_PATH}" || \
  (echo "Error going to ${ABSOLUTE_TARGET_PATH}" && exit 1)


## Start Jenkins in current state
docker-compose up -d --build --force-recreate -V
sleep 2

## Get Jenkins Public URL
JENKINS_URL="http://localhost:80/jenkins"
COUNTER=0
MAX_TRIES=60
WAIT_TIME=5
until [ "${COUNTER}" -ge "${MAX_TRIES}" ]
do
    # If the command fails, just return true, else break of the loop
    set +e
    curl -s -S -L -o /dev/null --fail --retry 3 --retry-delay 1 "${JENKINS_URL}" && break
    set -e
    COUNTER=$((COUNTER+1))
    sleep "${WAIT_TIME}"
done
[ "${COUNTER}" -lt "${MAX_TRIES}" ]

## Jenkins is started: We update installed plugins

# We use the jenkins container to be sure a compliant openjdk is installed
JENKINS_CLI_PATH=/tmp/jenkins-cli.jar
PLUGIN_TXT_LIST_FILE="$(mktemp)"
docker-compose exec jenkins curl -L -s -S -o "${JENKINS_CLI_PATH}" \
  "${JENKINS_PRIVATE_URL}/jnlpJars/jenkins-cli.jar"

# We fetch the list of plugins
docker-compose exec jenkins java -jar ${JENKINS_CLI_PATH} \
  -s "${JENKINS_PRIVATE_URL}" -auth "${JENKINS_ADMIN_USER}:${JENKINS_ADMIN_PASSWORD}" \
  list-plugins \
  | grep ')[[:cntrl:]]*$' \
  | awk '{ print $1 }' \
  > "${PLUGIN_TXT_LIST_FILE}"
echo "Plugin list written in ${PLUGIN_TXT_LIST_FILE}"

# We request a plugin install to latest version for each
if [ -n "$(cat "${PLUGIN_TXT_LIST_FILE}")" ]; then
  # Get list of plugin per id (no version: we want latest)
  sed ':a;N;$!ba;s/\n/ /g' > "${PLUGIN_TXT_LIST_FILE}.stripped" "${PLUGIN_TXT_LIST_FILE}"

  docker-compose exec jenkins java -jar "${JENKINS_CLI_PATH}" \
    -s "${JENKINS_PRIVATE_URL}" -auth "${JENKINS_ADMIN_USER}:${JENKINS_ADMIN_PASSWORD}" \
    install-plugin -restart \
    "$(sed ':a;N;$!ba;s/\n/ /g' "${PLUGIN_TXT_LIST_FILE}")"
fi
sleep 5
# Restart Jenkins
# docker-compose restart jenkins

popd

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
