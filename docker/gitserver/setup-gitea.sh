#!/bin/bash
#

set -e -o pipefail -x

# Parameters
GITSERVER_API_URL="${EXTERNAL_URL}/api/v1"
GITEA_RUN_USER="$(grep 'RUN_USER' ${SERVICE_CONFIG_FILE}* | sort | uniq | head -n1 | awk '{print $3}')"
CUSTOM_DATA_DIRECTORY="/app/data"

mkdir -p "${CUSTOM_DATA_DIRECTORY}"
chown -R "${GITEA_RUN_USER}:${GITEA_RUN_USER}" "${CUSTOM_DATA_DIRECTORY}"

# We need a prebaked configuration
cp "${SERVICE_CONFIG_FILE}.tmpl" "${SERVICE_CONFIG_FILE}"

# Launching the Gitserver
/usr/bin/entrypoint >/dev/stdout 2>&1 &

# Waiting for the Gitserver to start
TIME_TO_WAIT=2
while true; do
  curl --fail -s -v -X GET "${EXTERNAL_URL}" \
  && break ||
    echo "Gitserver still not started, waiting ${TIME_TO_WAIT}s before retrying"

  sleep "${TIME_TO_WAIT}"
done

echo "== Configuring Git Server"

# We create the first user
echo "=== Creating initial user as ${FIRST_USER}"
curl -v -X POST -s \
  -F "user_name=${FIRST_USER}" \
  -F "email=${FIRST_USER}@localhost.local" \
  -F "password=${FIRST_USER}" \
  -F "retype=${FIRST_USER}" \
  ${EXTERNAL_URL}/user/sign_up

if [ -n "${SOURCE_REPO_TO_MIRROR}" ]
then
  echo "=== Loading the custom repos"
  OLD_IFS=$IFS
  # The ';' char is allowed in URLs, but I assume the risk of having it
  # for git repos is low. If you find this case: find me, shout me :)
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


    echo "==== Cloning local repository /tmp/${REPO_NAME} from ${REMOTE_REPO_URL}"
    git clone --bare ${REMOTE_REPO_URL} /tmp/${REPO_NAME}


    echo "==== Creating repository ${REPO_NAME} inside Gitserver"
    curl -v -X POST -s \
      -F "name=${REPO_NAME}" \
      -F "private=${REPO_PRIVATE}" \
      -u "${FIRST_USER}:${FIRST_USER}" \
      ${GITSERVER_API_URL}/user/repos
    REPO_URL="$(echo ${EXTERNAL_URL} | sed "s#://#://${FIRST_USER}:${FIRST_USER}@#")/${FIRST_USER}/${REPO_NAME}"

    echo "==== Mirroring local repository /tmp/${REPO_NAME} to ${REPO_URL} in Gitserver"

    cd /tmp/${REPO_NAME} && git push --mirror ${REPO_URL} && cd -

  done
  rm -rf /tmp/* ~/.ssh/id_rsa
  IFS=$OLD_IFS
else
  echo "== No repo to mirror nor preload"
fi

echo "== Configuration done."
