#!/bin/bash

set -eux
set -o pipefail

# Get default Jenkins User
DEFAULT_UID="$(ls -nd ${JENKINS_AGENT_HOME} | awk '{print $3}')"
DEFAULT_USER="$(grep ${DEFAULT_UID} /etc/passwd | cut -f1 -d':')"
SOCKET_GROUP="docker"

# Get Socket group membership
SOCKET_GID="$(ls -n /var/run/docker.sock | awk '{print $4}')"

# If do not have already the docker group with the socker gid membership,
if [ ! "$(grep ${SOCKET_GID} /etc/group | grep ${SOCKET_GROUP})" ]
then
  # Do we already have a group with this GID to use ?
  if [ "$(grep :${SOCKET_GID}: /etc/group)" ]
  then
    SOCKET_GROUP="$(grep :${SOCKET_GID}: /etc/group | cut -d':' -f1)"
  else
    # Nope. Create a new dummy group then
    SOCKET_GROUP="docker-dummy"
    addgroup -g "${SOCKET_GID}" "${SOCKET_GROUP}"
  fi
fi

# Add the Default User to the socket group
addgroup "${DEFAULT_USER}" "${SOCKET_GROUP}"

# Run Parent Image entrypoint
bash /usr/local/bin/setup-sshd
