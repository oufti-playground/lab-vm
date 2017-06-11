#!/bin/sh

set -eux -o pipefail

BASE_DOMAIN="cloudbees-training.com"
. ../docker/.env
REGISTRY_URL="${BASE_DOMAIN}:5000"


export BASE_DOMAIN REGISTRY_URL EXTERNAL_PORT
