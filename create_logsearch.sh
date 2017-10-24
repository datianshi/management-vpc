
#!/bin/bash
set -e


director_name=$(bosh-cli int ./director.yml --path /director_name)
director=$(bosh-cli int ./director.yml --path /internal_ip)


export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh-cli int ${BOSH_WORK_DIR}/creds.yml --path /admin_password)

bosh-cli -n -e https://${director}:25555 alias-env ${director_name} \
  --ca-cert <(bosh-cli int ${BOSH_WORK_DIR}/creds.yml --path /default_ca/ca)

bosh-cli -n -e ${director_name} -d logsearch deploy logsearch/logsearch.yml --vars-file ./director.yml
