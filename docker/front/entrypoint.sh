#!/bin/sh

set -eux

TEMPLATES_TMP_DIR=/tmp/templates

DNS_RESOLVER_IP="$(grep nameserver /etc/resolv.conf  | head -n1 | awk '{print $2}')"
export DNS_RESOLVER_IP
# shellcheck disable=SC2046
ENV_VAR_LIST=$(printf '${%s} ' $(env | sort | uniq | cut -d'=' -f1 ))

export TEMPLATES_TMP_DIR ENV_VAR_LIST

# Get Template in a tmp folder
rm -rf "${TEMPLATES_TMP_DIR}"
cp -r /etc/nginx-templates "${TEMPLATES_TMP_DIR}"

# Render templates (using parenthesie for changing without messing up)
# Based on env vars
(
  cd /etc/nginx-templates
  find . -type f -exec sh -c '
    echo "-Found ${1}, rendering to: ${TEMPLATES_TMP_DIR}/${1}-"
    envsubst "${ENV_VAR_LIST}" <"${1}" >"${TEMPLATES_TMP_DIR}/${1}"
  ' sh {} \;
)

# Copy rendered inside Nginx, overwriting existing conf
cp -r "${TEMPLATES_TMP_DIR}"/* /etc/nginx/
chmod -R 755 /etc/nginx/

# Run nginx
nginx -g "daemon off;"
