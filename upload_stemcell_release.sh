#!/bin/bash
set -e


director=$(bosh-cli int ./director.yml --path /internal_ip)
director_name=$(bosh-cli int ./director.yml --path /director_name)

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh-cli int ${BOSH_WORK_DIR}/creds.yml --path /admin_password)

bosh-cli -n -e https://${director}:25555 alias-env ${director_name} \
  --ca-cert <(bosh-cli int ${BOSH_WORK_DIR}/creds.yml --path /default_ca/ca)

bosh-cli -e ${director_name} upload-release https://bosh.io/d/github.com/cloudfoundry/garden-runc-release?v=1.2.0
bosh-cli -e ${director_name} upload-release https://bosh.io/d/github.com/concourse/concourse?v=3.3.4
bosh-cli -e ${director_name} upload-release https://bosh.io/d/github.com/cloudfoundry-community/consul-boshrelease?v=22.0.0
bosh-cli -e ${director_name} upload-release https://bosh.io/d/github.com/cloudfoundry-community/vault-boshrelease?v=0.6.2
bosh-cli -e ${director_name} upload-release https://bosh.io/d/github.com/cloudfoundry-community/logsearch-boshrelease?v=208.0.0
bosh-cli -e ${director_name} upload-stemcell https://s3.amazonaws.com/bosh-aws-light-stemcells/light-bosh-stemcell-3468-aws-xen-hvm-ubuntu-trusty-go_agent.tgz
