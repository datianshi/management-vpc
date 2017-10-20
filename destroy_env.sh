#!/bin/bash

set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TSTATE_FILE="${DIR}/terraform.tfstate"

JUMPBOX_IP=$(terraform state show -state ${TSTATE_FILE} aws_instance.jumpbox | grep public_ip | tail -n 1 | awk '{print $3}')
ssh -tt -o "StrictHostKeyChecking=no" -i ${PRIVATE_KEY_PATH} ubuntu@${JUMPBOX_IP} 'bash -es' <<ENDSSH
  cd management-vpc
  source env.sh
  BOSH_WORK_DIR="../bosh_work" ./destroy_bosh.sh
  exit
ENDSSH
