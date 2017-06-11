#!/bin/bash -eux

PID_LIST=""


# Run Batch upgrades for workers
for MACHINE_NAME in $(docker-machine ls -q | grep 'prod-' | grep -v 'prod-m')
do
  ( docker-machine ssh "${MACHINE_NAME}" \
    'sudo apt-get update && sudo apt-get -y dist-upgrade && sudo reboot') &

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

# Run seq upgrade for managers
for MACHINE_NAME in $(docker-machine ls -q | grep 'prod-m')
do
  docker-machine ssh "${MACHINE_NAME}" \
    'sudo apt-get update && sudo apt-get -y dist-upgrade && sudo reboot'
done
