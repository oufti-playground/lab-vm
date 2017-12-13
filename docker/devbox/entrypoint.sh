#!/bin/bash

set -ex

# Lauch Docker Engine using parent image's entrypoint script
bash /usr/local/bin/dind-entrypoint.sh >/dev/stdout 2>&1 &

# Set default user git env
su -c "git config --global user.email ${DEFAULT_USER}@localhost.local" \
  "${DEFAULT_USER}"
su -c "git config --global user.name ${DEFAULT_USER}" "${DEFAULT_USER}"

# Custom CLI
echo 'export PS1="\u@devbox [\w]> "' \
  | tee -a /home/${DEFAULT_USER}/.bashrc

# Add some entropy
rngd -r /dev/urandom

# Launch TTYD server in foreground
cd "$(grep ${DEFAULT_USER} /etc/passwd | cut -d':' -f6)"
exec su -c "ttyd bash" "${DEFAULT_USER}"
