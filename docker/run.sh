#!/bin/sh
#
# This script is an example of customization script
# for https://github.com/dduportal/alpine2docker
# It will print the date to a file inside the VM root home

set -eux -o pipefail

MY_BASE_DIR="$(pwd -P)"

chown -R "${BASE_USER}:${BASE_USER}" "${MY_BASE_DIR}"

cd "${MY_BASE_DIR}"
ls -altrh

# Prepare environment
ENV_FILE="${MY_BASE_DIR}/.env"
EXTERNAL_DOMAIN=localhost
DOCKER_BRIDGE_IP="$(docker run --rm --net=host alpine ip -f inet -o addr show docker0 | awk '{print $4}' | cut -f1 -d'/')"
export EXTERNAL_DOMAIN DOCKER_BRIDGE_IP

sed -i '/EXTERNAL_DOMAIN/d' "${ENV_FILE}"
echo "EXTERNAL_DOMAIN=${EXTERNAL_DOMAIN}" >> "${ENV_FILE}"

sed -i '/DOCKER_BRIDGE_IP/d' "${ENV_FILE}"
echo "DOCKER_BRIDGE_IP=${DOCKER_BRIDGE_IP}" >> "${ENV_FILE}"

# Go go
docker-compose up --build -d
