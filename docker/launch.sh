#!/bin/sh
set -eux -o pipefail

# Prepare environment
ENV_FILE="/docker/.env"
EXTERNAL_DOMAIN="$(curl --connect-timeout 2 -sSL http://169.254.169.254/latest/meta-data/public-hostname || echo localhost)"
DOCKER_BRIDGE_IP="$(docker run --rm --net=host alpine ip -f inet -o addr show docker0 | awk '{print $4}' | cut -f1 -d'/')"
export EXTERNAL_DOMAIN DOCKER_BRIDGE_IP

sed -i '/EXTERNAL_DOMAIN/d' "${ENV_FILE}"
echo "EXTERNAL_DOMAIN=${EXTERNAL_DOMAIN}" >> "${ENV_FILE}"

sed -i '/DOCKER_BRIDGE_IP/d' "${ENV_FILE}"
echo "DOCKER_BRIDGE_IP=${DOCKER_BRIDGE_IP}" >> "${ENV_FILE}"

# Go go
docker-compose up --build --force-recreate -d

# Wait (do not forget to allocate a tty)
cat
