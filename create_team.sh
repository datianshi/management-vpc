#!/bin/bash



# PCF_ENV=test TEAM_USERNAME=test TEAM_PASSWORD=test OPSMAN_PASSWORD=admin ./create_team.sh

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TSTATE_FILE="${DIR}/terraform.tfstate"

JUMPBOX_IP=$(terraform state show -state ${TSTATE_FILE} aws_instance.jumpbox | grep public_ip | tail -n 1 | awk '{print $3}')
ssh -tt -o "StrictHostKeyChecking=no" -i ${PRIVATE_KEY_PATH} ubuntu@${JUMPBOX_IP} PIVNET_TOKEN=${PIVNET_TOKEN} \
PCF_ENV=${PCF_ENV} \
TEAM_USERNAME=${TEAM_USERNAME} \
TEAM_PASSWORD=${TEAM_PASSWORD} \
AWS_ACCESS_KEY=${TF_VAR_aws_access_key} \
AWS_SECRET_KEY=${TF_VAR_aws_secret_key} \
OPSMAN_PASSWORD=${OPSMAN_PASSWORD} \
'bash -es' <<ENDSSH
  cd management-vpc
  git pull origin master
  BOSH_WORK_DIR=../bosh_work TEAM_USERNAME=${TEAM_USERNAME} TEAM_PASSWORD=${TEAM_PASSWORD}   AWS_ACCESS_KEY=${AWS_ACCESS_KEY} AWS_SECRET_KEY=${AWS_SECRET_KEY} OPSMAN_PASSWORD=${OPSMAN_PASSWORD} ./concourse/prepare_team.sh
  exit
ENDSSH
