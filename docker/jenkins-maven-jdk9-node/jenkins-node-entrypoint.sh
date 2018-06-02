#!/bin/bash
#
# This script will launch the dockerd engine in background
# and launch SSH server

set -ex

write_key() {
	mkdir -p "${JENKINS_AGENT_HOME}/.ssh"
	echo "$1" > "${JENKINS_AGENT_HOME}/.ssh/authorized_keys"
	chown -Rf jenkins:jenkins "${JENKINS_AGENT_HOME}/.ssh"
	chmod 0700 -R "${JENKINS_AGENT_HOME}/.ssh"
}

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
