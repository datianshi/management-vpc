#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TSTATE_FILE="${DIR}/terraform.tfstate"
ENV_FILE="${DIR}/env.sh"


JUMPBOX_IP=$(terraform state show -state ${TSTATE_FILE} aws_instance.jumpbox | grep public_ip | tail -n 1 | awk '{print $3}')
ssh -tt -o "StrictHostKeyChecking=no" -i ${PRIVATE_KEY_PATH} ubuntu@${JUMPBOX_IP} 'bash -es' <<ENDSSH
  BOSH_WORK_DIR=../bosh_work
  cd management-vpc
  export BOSH_CLIENT=admin
  export BOSH_CLIENT_SECRET=$(bosh-cli int ${BOSH_WORK_DIR}/creds.yml --path /admin_password)
  director_name=$(bosh-cli int ./director.yml --path /director_name)
  bosh-cli -n -e ${director_name} -d concourse delete-deployment
  bosh-cli -n -e ${director_name} -d vault delete-deployment
  bosh-cli delete-env bosh-deployment/bosh.yml \
    --state ${BOSH_WORK_DIR}/state.json \
    -o bosh-deployment/aws/cpi.yml \
    --vars-store ${BOSH_WORK_DIR}/creds.yml \
    --vars-file ./director.yml
  exit
ENDSSH
