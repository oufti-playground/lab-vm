#!/bin/sh

set -eux -o pipefail

. load_env.sh

cd ../docker && docker-compose build && docker-compose push
