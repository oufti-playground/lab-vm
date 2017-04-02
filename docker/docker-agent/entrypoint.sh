#!/bin/bash

set -eux
set -o pipefail

# Get default Jenkins User
DEFAULT_UID="$(ls -nd ${JENKINS_AGENT_HOME} | awk '{print $3}')"
DEFAULT_USER="$(grep ${DEFAULT_UID} /etc/passwd | cut -f1 -d':')"

# Get Socket group membership
SOCKET_GROUP_MEMBERSHIP_UID="$(ls -n /var/run/docker.sock | awk '{print $4}')"


# Create the needed group to allow Jenkins Default User running docker CLI
if [ "$(grep -c ${SOCKET_GROUP_MEMBERSHIP_UID} /etc/group || true)" -ne 1 ]
then
  addgroup -g "${SOCKET_GROUP_MEMBERSHIP_UID}" docker
fi
SOCKET_GROUP_MEMBERSHIP="$(grep ${SOCKET_GROUP_MEMBERSHIP_UID} /etc/group | cut -f1 -d':')"

# Add the Default User to the socket group
addgroup "${DEFAULT_USER}" "${SOCKET_GROUP_MEMBERSHIP}"

# Run Parent Image entrypoint
bash /usr/local/bin/setup-sshd
