#!/bin/bash
set -e

cmd="bosh-cli create-env --state ./state.json"
if [ "${DRY_RUN}" == "true" ]
then
  cmd="bosh-cli int"
fi

command="$cmd bosh-deployment/bosh.yml \
  -o bosh-deployment/uaa.yml \
  -o bosh-deployment/aws/cpi.yml \
  --vars-store ./creds.yml \
  --vars-file ./director.yml"

echo $command
exec $command
