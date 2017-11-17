#!/bin/bash
#
# This script will launch the dockerd engine in background
# and try to load the docker-cache

## DOCKER_STORAGE--storage-driver=overlay2
set -ex

wait_for_docker_startup_or_exit() {
  # Wait for Docker startup
  local COUNTER=0
  local MAX_TRIES=3
  until [ "${COUNTER}" -ge "${MAX_TRIES}" ]
  do
    set +e
    curl -s --fail http://localhost:2375/_ping && break
    set -e
    COUNTER=$((COUNTER+1))
    sleep 10
  done
  [ "${COUNTER}" -lt "${MAX_TRIES}" ]
}

write_key() {
	mkdir -p "${JENKINS_USER_HOME}/.ssh"
	echo "$1" > "${JENKINS_USER_HOME}/.ssh/authorized_keys"
	chown -Rf jenkins:jenkins "${JENKINS_USER_HOME}/.ssh"
	chmod 0700 -R "${JENKINS_USER_HOME}/.ssh"
}

####
# Launch the DinD startup in background
# with logs on the standard output (for docker logs)
# only if START_DOCKER is true (default)
###

# Use DinD binary to launch Docker Engine with our own explicit opts
if [ "${START_DOCKER}" == "true" ]
then
  DOCKER_OPTS="--storage-driver=${DOCKER_STORAGE_DRIVER} --config-file=/etc/docker/daemon.json"
  ls -l /var/run/docker.sock || rm -f /var/run/docker.sock
  bash -x /usr/local/bin/dockerd-entrypoint.sh dockerd ${DOCKER_OPTS} >/dev/stdout 2>&1 &
  sleep 1

  ###
  # Load any "tar-ed" docker image from the local FS cache
  ###
  if [ -n "${DOCKER_IMAGE_CACHE_DIR}" ] && [ -d "${DOCKER_IMAGE_CACHE_DIR}" ]
  then
    wait_for_docker_startup_or_exit
    echo "== Loading Cache images"
    find "${DOCKER_IMAGE_CACHE_DIR}" -type f -name "*.tar" -exec docker load -i {} \;
  fi
else
  echo "-- START_DOCKER equals: ${START_DOCKER}. Not starting Docker."
fi

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

# Launch SSH server in foreground
exec /usr/sbin/sshd -D -e "${@}"
