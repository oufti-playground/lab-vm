#!/bin/bash
#
# This script will launch the dockerd engine in background
# and try to load the docker-cache if tar file founds

set -eu

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

####
# Launch the DinD startup in background
# with logs on the standard output (for docker logs)
# only if START_DOCKER is true (default)
###

if [ "${START_DOCKER}" == "true" ]
then
  DOCKER_OPTS="--storage-driver=${DOCKER_STORAGE_DRIVER} --config-file=/etc/docker/daemon.json"

  # Clean up previous docker instances
  ps faux | grep docker | grep -v grep | awk '{print $1}' | xargs kill || echo "Nothing to stop"
  ps faux | grep containerd | grep -v grep | awk '{print $1}' | xargs kill || echo "Nothing to stop"
  rm -rf /var/run/docker*

  # Launch Docker Engine (dind= Docker in Docker) in background in debug outputing to stdout
  bash -x /usr/local/bin/dockerd-entrypoint.sh dockerd ${DOCKER_OPTS} >/dev/stdout 2>&1 &

  # Wait 1 second to ensure slow I/O systems are able to start the parent docker engine process
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

echo "== Docker started, ${0} wrapper script finished successfully."

# Need to wait for Docker engine launched in background to stop
# because the container will stop as soon as the script exits
wait
