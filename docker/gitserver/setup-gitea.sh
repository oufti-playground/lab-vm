#!/bin/bash
#
set -ex -o pipefail

# Parameters
GITSERVER_BASE_URL="${EXTERNAL_URL:-http://localhost:3000}"
GITSERVER_API_URL="${GITSERVER_BASE_URL}/api/v1"
GITEA_RUN_USER=$(awk -F "=" '/RUN_USER/ {print $2}' ${SERVICE_CONFIG_FILE}* | tr -d ' ' | head -n1)
CUSTOM_DATA_DIRECTORY="/app/data"
WEBHOOKS_BASE_URL="http://jenkins:8080/jenkins/git/notifyCommit?url=ssh://git@gitserver:5022"

# Reusable functions

mirror_repository_into_local_gitserver() {

  REPO_NAME="${1}"
  shift

  REMOTE_REPO_URL="${1}"
  shift

  IS_PRIVATE="${1}"
  shift

  WEBHOOK="${1}"
  shift

  echo "==== Cloning local repository /tmp/${REPO_NAME} from ${REMOTE_REPO_URL}"
  git clone --bare "${REMOTE_REPO_URL}" "/tmp/${REPO_NAME}"

  echo "==== Creating repository ${REPO_NAME} inside Gitserver"
  curl -v --fail -X POST -s \
    -F "name=${REPO_NAME}" \
    -F "private=${IS_PRIVATE}" \
    -u "${FIRST_USER}:${FIRST_USER}" \
    "${GITSERVER_API_URL}/user/repos"
  REPO_URL="$(echo ${GITSERVER_BASE_URL} | sed "s#://#://${FIRST_USER}:${FIRST_USER}@#")/${FIRST_USER}/${REPO_NAME}"

  echo "==== Mirroring local repository /tmp/${REPO_NAME} to ${REPO_URL} in Gitserver"
  cd "/tmp/${REPO_NAME}" && git push --mirror "${REPO_URL}" && cd -

  if [ -n "${WEBHOOK}" ] && [ "${WEBHOOK}" == "true" ]
  then
    echo "==== Adding a Webhook with this payload URL: ${WEBHOOK}"

    WEBHOOK_URL="${WEBHOOKS_BASE_URL}/${FIRST_USER}/${REPO_NAME}.git"

    curl --fail -v -X POST -s \
      -u "${FIRST_USER}:${FIRST_USER}" \
      -H "accept: application/json" -H "Content-Type: application/json" \
      -d "{ \"active\": true, \"config\": { \"url\": \"${WEBHOOK_URL}\", \"content_type\": \"json\" }, \"events\": [ \"push\",\"create\", \"pull_request\",\"repository\"], \"type\": \"gitea\"}" \
      "${GITSERVER_API_URL}/repos/${FIRST_USER}/${REPO_NAME}/hooks"
  fi
}

if [ "${1}" == "start-gitserver" ]
then
  # Initial checks
  id -u ${GITEA_RUN_USER} || (echo "${GITEA_RUN_USER} user does not exists" && exit 1)
  mkdir -p "${CUSTOM_DATA_DIRECTORY}"
  chown -R "${GITEA_RUN_USER}" "${CUSTOM_DATA_DIRECTORY}"

  # We need a prebaked configuration
  cp "${SERVICE_CONFIG_FILE}.tmpl" "${SERVICE_CONFIG_FILE}"

  # Launching the Gitserver
  nohup /usr/bin/entrypoint >/dev/stdout 2>/dev/stdout &
fi

# Waiting for the Gitserver to start
TIME_TO_WAIT=2
while true; do
  curl -sSL -o /dev/null --fail "${GITSERVER_BASE_URL}" \
  && break ||
    echo "Gitserver still not started, waiting ${TIME_TO_WAIT}s before retrying"

  sleep "${TIME_TO_WAIT}"
done

echo "== Configuring Git Server"

# We create the first user
echo "=== Creating initial user as ${FIRST_USER}"
curl --fail -v -X POST -s \
  -F "user_name=${FIRST_USER}" \
  -F "email=${FIRST_USER}@localhost.local" \
  -F "password=${FIRST_USER}" \
  -F "retype=${FIRST_USER}" \
  ${GITSERVER_BASE_URL}/user/sign_up

if [ -n "${SOURCE_REPO_TO_MIRROR}" ]
then
  echo "=== Loading the custom repos"
  OLD_IFS=$IFS
  # The ';' char is allowed in URLs, but I assume the risk of having it
  # for git repos is low. If you find this case: find me, shoot me :)
  IFS=';'

  #Use /tmp to fetch a SSH key
  if [ -f "/tmp/id_rsa" ]
  then
    mkdir -p ~/.ssh
    cp /tmp/id_rsa ~/.ssh/
    echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
    chmod 0700 ~/.ssh
    chmod 0600 ~/.ssh/id*
  fi

  for REPO in $SOURCE_REPO_TO_MIRROR
  do
    REMOTE_REPO_URL="$(echo ${REPO} | cut -f1 -d'|')"
    REPO_NAME="$(echo ${REPO} | cut -f2 -d'|')"
    REPO_VISIBILITY="$(echo ${REPO} | cut -f3 -d'|')"
    if [ -n "${REPO_VISIBILITY}" ] && [ "${REPO_VISIBILITY}" = "private" ]
    then
      REPO_PRIVATE=true
    else
      REPO_PRIVATE=false
    fi
    if [ -n "$(echo ${REPO} | cut -f4 -d'|')" ]
    then
      WEBHOOK=true
    else
      WEBHOOK=false
    fi

    mirror_repository_into_local_gitserver \
      "${REPO_NAME}" \
      "${REMOTE_REPO_URL}" \
      "${REPO_PRIVATE}" \
      "${WEBHOOK}"

  done
  rm -rf /tmp/* ~/.ssh/id_rsa
  IFS=$OLD_IFS
else
  echo "== No repo to mirror nor preload"
fi

touch "${CUSTOM_DATA_DIRECTORY}/.semaphore"
echo "== Configuration done."
