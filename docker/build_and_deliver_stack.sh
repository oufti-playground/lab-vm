#!/bin/sh

set -eux -o pipefail

. .load_env.sh

docker-compose build
docker-compose push
