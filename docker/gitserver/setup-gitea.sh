#!/bin/bash
#
set -ex -o pipefail

# Parameters
GITSERVER_BASE_URL="${GITSERVER_BASE_URL:-http://localhost:3000}"
GITSERVER_API_URL="${GITSERVER_BASE_URL}/api/v1"
GITEA_RUN_USER=$(awk -F "=" '/RUN_USER/ {print $2}' "${SERVICE_CONFIG_FILE}"* | tr -d ' ' | head -n1)
CUSTOM_DATA_DIRECTORY="/app/data"

# Reusable functions
log_message() {
  echo "[setup-gitea] ${*}"
}

mirror_repository_into_local_gitserver() {

  local REPOSITORY_NAME="${1}"
  shift

  local REMOTE_REPOSITORY_URL="${1}"
  shift

  local IS_PRIVATE="${1}"
  shift

  local WEBHOOK_URL="${1}"
  shift

  local SSH_PRIVATE_KEY="${1}"
  shift

  GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
  if [ -n "${SSH_PRIVATE_KEY}" ] && [ -f "${SSH_PRIVATE_KEY}" ]
  then
    chmod 0600 "${SSH_PRIVATE_KEY}"
    ls -l "${SSH_PRIVATE_KEY}"
    GIT_SSH_COMMAND="${GIT_SSH_COMMAND} -i ${SSH_PRIVATE_KEY}"
  fi

  export GIT_SSH_COMMAND

  log_message "==== Cloning local repository /tmp/${REPOSITORY_NAME} from ${REMOTE_REPOSITORY_URL}"
  git clone --bare "${REMOTE_REPOSITORY_URL}" "/tmp/${REPOSITORY_NAME}"

  log_message "==== Creating repository ${REPOSITORY_NAME} inside Gitserver"
  curl -v --fail -X POST -s \
    -F "name=${REPOSITORY_NAME}" \
    -F "private=${IS_PRIVATE}" \
    -u "${FIRST_USER}:${FIRST_USER}" \
    "${GITSERVER_API_URL}/user/repos"

  # shellcheck disable=SC2001
  REPOSITORY_URL="$(echo "${GITSERVER_BASE_URL}" | sed "s#://#://${FIRST_USER}:${FIRST_USER}@#")/${FIRST_USER}/${REPOSITORY_NAME}"

  log_message "==== Mirroring local repository /tmp/${REPOSITORY_NAME} to ${REPOSITORY_URL} in Gitserver"
  cd "/tmp/${REPOSITORY_NAME}" && git push --mirror "${REPOSITORY_URL}" && cd -

  if [ -n "${WEBHOOK_URL}" ] && [ "${WEBHOOK_URL}" != "none" ]
  then
    log_message "==== Adding a Webhook with this payload URL: ${WEBHOOK_URL}"

    curl --fail -v -X POST -s \
      -u "${FIRST_USER}:${FIRST_USER}" \
      -H "accept: application/json" -H "Content-Type: application/json" \
      -d "{ \"active\": true, \"config\": { \"url\": \"${WEBHOOK_URL}\", \"content_type\": \"json\" }, \"events\": [ \"push\",\"create\", \"pull_request\",\"repository\"], \"type\": \"gitea\"}" \
      "${GITSERVER_API_URL}/repos/${FIRST_USER}/${REPOSITORY_NAME}/hooks"
  fi
}

if [ "${1}" == "start-gitserver" ]
then
  # Initial checks
  id -u "${GITEA_RUN_USER}" \
    || (echo "${GITEA_RUN_USER} user does not exists" && exit 1)
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
  # shellcheck disable=SC2015
  curl -sSL -o /dev/null --fail "${GITSERVER_BASE_URL}" \
  && break ||
    log_message "Gitserver still not started, waiting ${TIME_TO_WAIT}s before retrying"

  sleep "${TIME_TO_WAIT}"
done

log_message "== Configuring Git Server"

# We create the first user
log_message "=== Creating initial user as ${FIRST_USER}"
TIME_TO_WAIT=2
while true; do
  # shellcheck disable=SC2015
  curl --fail -v -X POST -s \
    -F "user_name=${FIRST_USER}" \
    -F "email=${FIRST_USER}@localhost.local" \
    -F "password=${FIRST_USER}" \
    -F "retype=${FIRST_USER}" \
    "${GITSERVER_BASE_URL}/user/sign_up" && break \
    || log_message "Could not create initial user ${FIRST_USER}: got an HTTP error. Waiting ${TIME_TO_WAIT}s before retrying"

  sleep "${TIME_TO_WAIT}"
done


if [ -n "${SOURCE_REPO_CONFIG}" ] && [ -f "${SOURCE_REPO_CONFIG}" ]
then
  log_message "=== Loading definition of custom repositories from ${SOURCE_REPO_CONFIG}"

  for REPOSITORY_DEFINITION in $(jq -r -c '.repositories[]' \
    "${SOURCE_REPO_CONFIG}")
  do
    REPOSITORY_NAME="$(echo "${REPOSITORY_DEFINITION}" \
      | jq -r -c '.name')"
    REMOTE_REPOSITORY_URL="$(echo "${REPOSITORY_DEFINITION}" \
      | jq -r -c '.url')"
    REPOSITORY_VISIBILITY="$(echo "${REPOSITORY_DEFINITION}" \
      | jq -r -c '.visibility' 2>/dev/null || echo 'public')"
    REPOSITORY_KEY="$(echo "${REPOSITORY_DEFINITION}" \
      | jq -r -c '.private_key'  2>/dev/null || echo 'none')"
    REPOSITORY_WEBHOOK="$(echo "${REPOSITORY_DEFINITION}" \
      | jq -r -c '.webhook_url' 2>/dev/null || echo 'none')"


    if [ -n "${REPOSITORY_VISIBILITY}" ] && [ "${REPOSITORY_VISIBILITY}" = "private" ]
    then
      REPOSITORY_PRIVATE=true
    else
      REPOSITORY_PRIVATE=false
    fi

    mirror_repository_into_local_gitserver \
      "${REPOSITORY_NAME}" \
      "${REMOTE_REPOSITORY_URL}" \
      "${REPOSITORY_PRIVATE}" \
      "${REPOSITORY_WEBHOOK}" \
      "${REPOSITORY_KEY}"

  done
else
  log_message "=== No definition of custom repositories found."
fi

touch "${CUSTOM_DATA_DIRECTORY}/.semaphore"
log_message "== Configuration done."
