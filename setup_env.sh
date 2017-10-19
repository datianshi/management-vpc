#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TSTATE_FILE="${DIR}/terraform.tfstate"
ENV_FILE="${DIR}/env.sh"


JUMPBOX_IP=$(terraform state show -state ${TSTATE_FILE} aws_instance.jumpbox | grep public_ip | tail -n 1 | awk '{print $3}')


ssh -o "StrictHostKeyChecking=no" -i ${PRIVATE_KEY_PATH} ubuntu@${JUMPBOX_IP} 'rm -rf management-vpc && git clone https://github.com/datianshi/management-vpc'
scp -o "StrictHostKeyChecking=no" -i ${PRIVATE_KEY_PATH} ${TSTATE_FILE} ${ENV_FILE} ${PRIVATE_KEY_PATH} ubuntu@${JUMPBOX_IP}:./management-vpc/
ssh -tt -o "StrictHostKeyChecking=no" -i ${PRIVATE_KEY_PATH} ubuntu@${JUMPBOX_IP} 'bash -s' <<ENDSSH
  cd management-vpc
  source env.sh
  git submodule init && git submodule update
  ./generate_director_yml.sh
  ./create-bosh.sh
  BOSH_WORK_DIR=../bosh_work ./create_cloud_config.sh
  BOSH_WORK_DIR=../bosh_work ./upload_stemcell_release.sh
  BOSH_WORK_DIR=../bosh_work ./create_vault.sh
  BOSH_WORK_DIR=../bosh_work ./create_concourse.sh
  exit
ENDSSH
