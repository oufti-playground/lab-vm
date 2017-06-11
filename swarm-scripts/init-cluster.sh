#!/bin/bash -eux
#
## TODO: replace by terraform !

# Common settings
MAIN_DOMAIN="cloudbees-training.com"
REGISTRY_URL="${MAIN_DOMAIN}:5000"
AWS_REGION="us-east-1"
AWS_ZONE="b"

# Cluster size
MANAGER_NUM=3
MANAGER_TYPE=t2.small
MANAGER_SG=docker-machine

ADMIN_WORKER_NUM=3
ADMIN_TYPE=i3.large
ADMIN_SG=docker-machine

APP_WORKER_NUM=2
APP_TYPE=m4.xlarge
APP_SG=docker-machine

SWARM_MANAGER_TOKEN=""
SWARM_WORKER_TOKEN=""
SWARM_JOIN_ADDRESS=""

### Create Managers
if [ "${MANAGER_NUM}" -ge 1 ]
then
  # Create remote nodes in parallel
  PID_LIST=""

  for MANAGER_ID in $(seq 1 "${MANAGER_NUM}")
  do
    MACHINE_NAME="prod-m${MANAGER_ID}"
    ( docker-machine create --driver amazonec2 \
      --amazonec2-security-group "${MANAGER_SG}" \
      --amazonec2-instance-type "${MANAGER_TYPE}" \
      --engine-insecure-registry "${REGISTRY_URL}" \
      --amazonec2-region "${AWS_REGION}" \
      --amazonec2-zone "${AWS_ZONE}" \
      --engine-label family=admin \
      "${MACHINE_NAME}" ) &

    # store PID of process
    PID_LIST+=" $!"
  done

  # Waiting for all master to be up
  for PID in ${PID_LIST}
  do
    if wait $PID; then
      echo "Process ${PID} success"
    else
      echo "Process ${PID} fail"
    fi
  done

  # Swarm init
  for MANAGER_ID in $(seq 1 "${MANAGER_NUM}")
  do
    MANAGER_NAME="prod-m${MANAGER_ID}"
    eval "$(docker-machine env ${MANAGER_NAME})"

    if [ "${MANAGER_ID}" -eq 1 ]
    then
      # Init Swarm Mode
      docker swarm init
      SWARM_JOIN_ADDRESS="$(docker swarm join-token manager | grep 2377 | awk '{print $1}')"

      # Set variables
      SWARM_MANAGER_TOKEN="$(docker swarm join-token manager -q)"
      SWARM_WORKER_TOKEN="$(docker swarm join-token worker -q)"

      # Export Variables if everything is set up
      export SWARM_MANAGER_TOKEN SWARM_WORKER_TOKEN SWARM_JOIN_ADDRESS
    else
      # Join Swarm as manager (variables should have been set)
      docker swarm join --token "${SWARM_MANAGER_TOKEN}" "${SWARM_JOIN_ADDRESS}"
    fi
  done
fi



### Create Admin Workers
if [ "${ADMIN_WORKER_NUM}" -ge 1 ]
then
  # Create remote nodes in parallel
  PID_LIST=""

  for ADMIN_WORKER_ID in $(seq 1 "${ADMIN_WORKER_NUM}")
  do
    MACHINE_NAME="prod-a${ADMIN_WORKER_ID}"
    ( docker-machine create --driver amazonec2 \
      --amazonec2-security-group "${ADMIN_SG}" \
      --amazonec2-instance-type "${ADMIN_TYPE}" \
      --engine-insecure-registry "${REGISTRY_URL}" \
      --amazonec2-region "${AWS_REGION}" \
      --amazonec2-zone "${AWS_ZONE}" \
      --engine-label family=admin \
      "${MACHINE_NAME}" ) &

    # store PID of process
    PID_LIST+=" $!"
  done

  # Waiting for all master to be up
  for PID in ${PID_LIST}
  do
    if wait $PID; then
      echo "Process ${PID} success"
    else
      echo "Process ${PID} fail"
    fi
  done

  # Swarm join
  for ADMIN_WORKER_ID in $(seq 1 "${ADMIN_WORKER_NUM}")
  do
    ADMIN_WORKER_NAME="prod-a${ADMIN_WORKER_ID}"
    eval "$(docker-machine env ${ADMIN_WORKER_NAME})"
    docker swarm join --token "${SWARM_WORKER_TOKEN}" "${SWARM_JOIN_ADDRESS}"
  done
fi

### Create App Workers
if [ "${APP_WORKER_NUM}" -ge 1 ]
then
  # Create remote nodes in parallel
  PID_LIST=""

  for APP_WORKER_ID in $(seq 1 "${APP_WORKER_NUM}")
  do
    MACHINE_NAME="prod-w${APP_WORKER_ID}"
    ( docker-machine create --driver amazonec2 \
      --amazonec2-security-group "${APP_SG}" \
      --amazonec2-instance-type "${APP_TYPE}" \
      --engine-insecure-registry "${REGISTRY_URL}" \
      --amazonec2-region "${AWS_REGION}" \
      --amazonec2-zone "${AWS_ZONE}" \
      --engine-label family=app \
      "${MACHINE_NAME}" ) &

    # store PID of process
    PID_LIST+=" $!"
  done

  # Waiting for all master to be up
  for PID in ${PID_LIST}
  do
    if wait $PID; then
      echo "Process ${PID} success"
    else
      echo "Process ${PID} fail"
    fi
  done

  # Swarm join
  for APP_WORKER_ID in $(seq 1 "${APP_WORKER_NUM}")
  do
    APP_WORKER_NAME="prod-w${APP_WORKER_ID}"
    eval "$(docker-machine env ${APP_WORKER_NAME})"
    docker swarm join --token "${SWARM_WORKER_TOKEN}" "${SWARM_JOIN_ADDRESS}"
  done
fi

# Quick recap at the end
eval "$(docker-machine env prod-m1)"
docker node ls
