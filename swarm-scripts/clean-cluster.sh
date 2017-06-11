#!/bin/bash -eu

PID_LIST=""

for MACHINE_NAME in $(docker-machine ls -q | grep 'prod-')
do
  ( eval "$(docker-machine env ${MACHINE_NAME})" && docker system prune -f ) &

  # store PID of process
  PID_LIST+=" $!"
done

for PID in ${PID_LIST}
do
  if wait $PID; then
    echo "Process ${PID} success"
  else
    echo "Process ${PID} fail"
  fi
done
