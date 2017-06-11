#!/bin/bash

set -eux -o pipefail

# source ../docker/.env
# while read -r line; do declare  $line; done <../docker/.env
read_properties()
{
  file="$1"
  while IFS="=" read -r key value; do
    case "$key" in
      '#'*) ;;
      *)
        eval "$key=\"$value\""
    esac
  done < "$file"
}

BASE_DOMAIN="cloudbees-training.com"
read_properties "../docker/.env"
REGISTRY_URL="${BASE_DOMAIN}:5000"


export BASE_DOMAIN REGISTRY_URL EXTERNAL_PORT
