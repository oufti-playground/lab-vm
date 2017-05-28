#!/bin/sh

set -eux -o pipefail

. .load_env.sh

COMPOSE_PROJECT_NAME="${1}"
EXTERNAL_DOMAIN="${COMPOSE_PROJECT_NAME}.${BASE_DOMAIN}"

export COMPOSE_PROJECT_NAME EXTERNAL_DOMAIN

docker stack deploy --compose-file docker-compose.yml "${COMPOSE_PROJECT_NAME}"
