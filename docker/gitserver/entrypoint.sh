#!/bin/sh
#
# Custom Entrypoint for Gite that will render templates before starting
#

set -ex -o pipefail

# Check if we need custom configuration (can be done at runtime instead of build time)
set +u
if [ ! -f /app/data/.semaphore ] && [ -n "${SOURCE_REPO_TO_MIRROR}" ] && [ -n "${FIRST_USER}" ]
then
  echo "== No Semaphore file found in /app/data/.semaphore"
  echo "=> Conditions found for runtime customization. Launching in background"

  # Run customization in background
  nohup bash /app/setup-gitea.sh >/dev/stdout 2>/dev/stdout &
fi
set -u

cat "${SERVICE_CONFIG_FILE}.tmpl" \
  | sed "s#ROOT_URL.*=.*#ROOT_URL = ${EXTERNAL_URL}#g" \
  | sed "s#^DOMAIN.*#DOMAIN = ${EXTERNAL_DOMAIN}#g" \
  | tee /data/gitea/conf/app.ini

 # Run the SSH key loader in background if requested
if [ "${LOAD_SSH_KEY_FROM_JENKINS}" = "true" ]
then
  nohup bash /usr/local/bin/set-key-from-jenkins-to-gitea.sh >/dev/stdout 2>/dev/stdout &
fi

# Standard entrypoint
exec /usr/bin/entrypoint
