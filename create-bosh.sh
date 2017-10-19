#!/bin/bash
set -e

BOSH_WORK_DIR="../bosh_work"
mkdir -p ${BOSH_WORK_DIR}
cmd="bosh-cli create-env --state ${BOSH_WORK_DIR}/state.json"
if [ "${DRY_RUN}" == "true" ]
then
  cmd="bosh-cli int"
fi

command="$cmd bosh-deployment/bosh.yml \
  -o bosh-deployment/uaa.yml \
  -o bosh-deployment/aws/cpi.yml \
  --vars-store ${BOSH_WORK_DIR}/creds.yml \
  --vars-file ./director.yml"

echo $command
exec $command
