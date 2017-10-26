#!/bin/bash
set -e

director=$(bosh-cli int ./director.yml --path /internal_ip)
director_name=$(bosh-cli int ./director.yml --path /director_name)

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh-cli int ${BOSH_WORK_DIR}/creds.yml --path /admin_password)

bosh-cli -n -e ${director_name} -d vault delete-deployment
bosh-cli -n -e ${director_name} -d concourse delete-deployment
#bosh-cli -n -e ${director_name} -d logsearch delete-deployment
bosh-cli -n -e ${director_name} clean-up --all

bosh-cli -n delete-env bosh-deployment/bosh.yml \
  --state ./${BOSH_WORK_DIR}/state.json \
  -o bosh-deployment/aws/cpi.yml \
  --vars-store ${BOSH_WORK_DIR}/creds.yml \
  --vars-file ./director.yml
