#!/bin/bash
set -e


director=$(bosh-cli int ./director.yml --path /internal_ip)
director_name=$(bosh-cli int ./director.yml --path /director_name)

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh-cli int ${BOSH_WORK_DIR}/creds.yml --path /admin_password)

bosh-cli -n -e https://${director}:25555 alias-env ${director_name} \
  --ca-cert <(bosh-cli int ${BOSH_WORK_DIR}/creds.yml --path /default_ca/ca)


bosh-cli -n -e ${director_name} update-cloud-config cloud-config/cloud_config.yml \
  -o cloud-config/reserved_range.yml \
  -o cloud-config/cloud_config_ops.yml \
  --vars-file ./director.yml \
  --ca-cert <(bosh-cli int ${BOSH_WORK_DIR}/creds.yml --path /default_ca/ca)
