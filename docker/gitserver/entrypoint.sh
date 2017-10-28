#!/bin/sh
#
# Custom Entrypoint for Gite that will render templates before starting
#

cat "${SERVICE_CONFIG_FILE}.tmpl" \
  | sed "s#ROOT_URL.*=.*#ROOT_URL = ${EXTERNAL_URL}#g" \
  | sed "s#^DOMAIN.*#DOMAIN = ${EXTERNAL_DOMAIN}#g" \
  | tee /data/gitea/conf/app.ini

# Standard entrypoint
exec /usr/bin/entrypoint
