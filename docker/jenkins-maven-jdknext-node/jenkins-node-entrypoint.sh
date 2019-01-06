#!/bin/bash
#
# This script will launch the dockerd engine in background
# and launch SSH server

set -ex

write_key() {
	mkdir -p "${DEFAULT_USER_HOME}/.ssh"
	echo "$1" > "${DEFAULT_USER_HOME}/.ssh/authorized_keys"
	chown -Rf jenkins:jenkins "${DEFAULT_USER_HOME}/.ssh"
	chmod 0700 -R "${DEFAULT_USER_HOME}/.ssh"
}

# Lauch Docker Engine using parent image's entrypoint script
bash /usr/local/bin/dind-entrypoint.sh >/dev/stdout 2>&1 &

# Set SSH runtime settings
if [[ $JENKINS_SLAVE_SSH_PUBKEY == ssh-* ]]; then
  write_key "${JENKINS_SLAVE_SSH_PUBKEY}"
fi
if [[ $# -gt 0 ]]; then
  if [[ $1 == ssh-* ]]; then
    write_key "$1"
    shift 1
  else
    exec "$@"
  fi
fi
ssh-keygen -A

# Launch SSH server in foreground (no need to wait for background processes)
exec /usr/sbin/sshd -D -e "${@}"
