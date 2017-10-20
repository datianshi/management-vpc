#!/bin/bash
set -e

bosh-cli delete-env bosh-deployment/bosh.yml \
  --state ./${BOSH_WORK_DIR}/state.json \
  -o bosh-deployment/${BOSH_WORK_DIR}/cpi.yml \
  --vars-store ${BOSH_WORK_DIR}/creds.yml \
  --vars-file ./director.yml
