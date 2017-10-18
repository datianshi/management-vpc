#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TSTATE_FILE="${DIR}/terraform.tfstate"
ENV_FILE="${DIR}/env.sh"


JUMPBOX_IP=$(terraform state show -state ${TSTATE_FILE} aws_instance.jumpbox | grep public_ip | tail -n 1 | awk '{print $3}')


ssh -o "StrictHostKeyChecking=no" -i ${PRIVATE_KEY_PATH} ubuntu@${JUMPBOX_IP} 'rm -rf management-vpc && git clone https://github.com/datianshi/management-vpc'
#ssh -i ${PRIVATE_KEY_PATH} ubuntu@${JUMPBOX_IP} 'cd management-vpc && git submodule init && git submodule update'
scp -o "StrictHostKeyChecking=no" -i ${PRIVATE_KEY_PATH} ${TSTATE_FILE} ${ENV_FILE} ${PRIVATE_KEY_PATH} ubuntu@${JUMPBOX_IP}:./management-vpc/
ssh -o "StrictHostKeyChecking=no" -i ${PRIVATE_KEY_PATH} ubuntu@${JUMPBOX_IP} 'bash -s' <<ENDSSH
  cd management-vpc
  source env.sh
  ./generate_director_yml.sh
ENDSSH
