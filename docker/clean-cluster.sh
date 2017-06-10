#!/bin/bash -eux

for MACHINE in $(docker-machine ls | grep prod- | awk '{print $1}')
do
  eval "$(docker-machine env ${MACHINE})"
  docker system prune -f
done
