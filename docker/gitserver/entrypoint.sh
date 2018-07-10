#!/bin/sh
#
# Custom Entrypoint for Gite that will render templates before starting
#

set -ex

DATA_DIR=/app/data

# Reusable functions
log_message() {
  echo "[entrypoint] ${*}"
}

set +u
# Check if we need custom configuration (can be done at runtime instead of build time)
if [ ! -f "${DATA_DIR}/.semaphore" ] && [ -n "${FIRST_USER}" ]
then
  log_message "== No Semaphore file found in ${DATA_DIR}/.semaphore"
  log_message "=> Conditions found for runtime customization. Launching in background"

  # Run customization in background
  nohup bash /app/setup-gitea.sh >/dev/stdout 2>&1 &
fi
set -u

# Ensure we have the $DATA_DIR created with the rights
mkdir -p "${DATA_DIR}"
chown -R 1000:1000 "${DATA_DIR}"

sed "s#ROOT_URL.*=.*#ROOT_URL = ${EXTERNAL_URL}#g" \
  "${SERVICE_CONFIG_FILE}.tmpl" \
  | sed "s#^DOMAIN.*#DOMAIN = ${EXTERNAL_DOMAIN}#g" \
  | tee /data/gitea/conf/app.ini

 # Run the SSH key loader in background if requested
if [ "${LOAD_SSH_KEY_FROM_JENKINS}" = "true" ]
then
  nohup bash /usr/local/bin/set-key-from-jenkins-to-gitea.sh >/dev/stdout 2>/dev/stdout &
fi

# Standard entrypoint
exec /usr/bin/entrypoint
