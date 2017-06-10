#!/bin/sh

set -eux -o pipefail

BASE_DOMAIN="cloudbees-training.com"
. .env
REGISTRY_URL="${BASE_DOMAIN}:5001"


export BASE_DOMAIN REGISTRY_URL EXTERNAL_PORT
