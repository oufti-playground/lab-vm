#!/bin/sh
#
# This script is an example of customization script
# for https://github.com/dduportal/alpine2docker
# It will print the date to a file inside the VM root home

set -eux -o pipefail

MY_BASE_DIR="$(pwd -P)"


cd "${MY_BASE_DIR}"
ls -altrh

# Prepare volumes
docker-compose up --build -d
