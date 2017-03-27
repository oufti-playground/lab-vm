#!/bin/sh
#
# This script will auto-configure a "blank" app stack for the demo

set -eu

# Uncomment to enable debug mode
# set -x

# Parameters
GITSERVER_API_URL="${EXTERNAL_URL}/api/v1"
GIT_REPO_URL="${EXTERNAL_URL}/${FIRST_USER}/${FIRST_REPO_NAME}.git"
GIT_REPO_AUTH_URL=$(echo "${GIT_REPO_URL}" | sed "s#http://#http://${FIRST_USER}:${FIRST_USER}@#g")
GITEA_RUN_USER="$(grep 'RUN_USER' /etc/templates/app.ini | awk '{print $3}')"
CUSTOM_DATA_DIRECTORY="/app/data"

mkdir -p "${CUSTOM_DATA_DIRECTORY}"
chown -R "${GITEA_RUN_USER}:${GITEA_RUN_USER}" "${CUSTOM_DATA_DIRECTORY}"

# Launching Gitea
/usr/bin/entrypoint /bin/s6-svscan /etc/s6 >/dev/stdout 2>&1 &

# Waiting for Gitserver to start
while true; do
  curl --fail -X GET "${EXTERNAL_URL}" \
  && break ||
    echo "Git Server still not started, waiting 2s before retrying"

  sleep 5
done

echo "== Configuring Git Server"

# We create the first user
curl -v -X POST -s \
  -F "user_name=${FIRST_USER}" \
  -F "email=${FIRST_USER}@localhost.local" \
  -F "password=${FIRST_USER}" \
  -F "retype=${FIRST_USER}" \
  ${EXTERNAL_URL}/user/sign_up

# Create initial repository
curl -v -X POST -s \
  -F "uid=1" \
  -F "name=${FIRST_REPO_NAME}" \
  -u "${FIRST_USER}:${FIRST_USER}" \
  ${GITSERVER_API_URL}/user/repos

# Load our local repository inside the newly created one
git clone --bare ${SOURCE_REPO_TO_MIRROR} "/tmp/${FIRST_REPO_NAME}"
( cd "/tmp/${FIRST_REPO_NAME}" \
    && git push --mirror ${GIT_REPO_AUTH_URL}
)
rm -rf /tmp/*

echo "== Configuration done."
