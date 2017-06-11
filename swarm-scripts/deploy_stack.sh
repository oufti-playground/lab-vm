#!/bin/sh

set -eux -o pipefail

. load_env.sh

COMPOSE_PROJECT_NAME="${1}"
COMPOSE_FILE="${2:-../docker/docker-compose.yml}"
EXTERNAL_DOMAIN="${COMPOSE_PROJECT_NAME}.${BASE_DOMAIN}"

export COMPOSE_PROJECT_NAME EXTERNAL_DOMAIN

cd "$(dirname ${COMPOSE_FILE})" \
  && docker stack deploy --compose-file "${COMPOSE_FILE}" "${COMPOSE_PROJECT_NAME}"
