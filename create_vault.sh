
#!/bin/bash
set -e


director_name=$(bosh-cli int ./director.yml --path /director_name)
director=$(bosh-cli int ./director.yml --path /internal_ip)


export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh-cli int ${BOSH_WORK_DIR}/creds.yml --path /admin_password)

bosh-cli -n -e https://${director}:25555 alias-env ${director_name} \
  --ca-cert <(bosh-cli int ${BOSH_WORK_DIR}/creds.yml --path /default_ca/ca)

bosh-cli -n -e ${director_name} -d vault deploy vault/vault.yml --vars-file ./director.yml --vars-store ${BOSH_WORK_DIR}/vault_creds.yml

export VAULT_IP=$(bosh-cli int ./director.yml --path /vault_static_ips/0)
set +e
VAULT_ADDR=https://${VAULT_IP}:8200 VAULT_SKIP_VERIFY=true vault init -check
if [ $? == 2 ]
then
    set -e
    echo "Initialize Vault"
    VAULT_ADDR=https://${VAULT_IP}:8200 VAULT_SKIP_VERIFY=true vault init | head -n 6 > ${BOSH_WORK_DIR}/vault_init_creds
    for n in {1..3}
    do
      key=$(bosh-cli int ${BOSH_WORK_DIR}/vault_init_creds --path "/Unseal Key ${n}")
      VAULT_ADDR=https://${VAULT_IP}:8200 VAULT_SKIP_VERIFY=true vault unseal ${key}
    done
    VAULT_ADDR=https://${VAULT_IP}:8200 VAULT_SKIP_VERIFY=true vault mount -path=/concourse -description="Secrets for concourse pipelines" generic
    ROOT_TOKEN=$(bosh-cli int ${BOSH_WORK_DIR}/vault_init_creds --path "/Initial Root Token")
    vault auth -token-only - <<< "${ROOT_TOKEN}"
    vault policy-write policy-concourse - <<EOF
path "concourse/*" {
  policy = "read"
  capabilities =  ["read", "list"]
}
EOF
    concourse_token=$(vault token-create --policy=policy-concourse -period="600h" -format=json | jq .token)
    echo "concourse_token: ${concourse_token}" >> ${BOSH_WORK_DIR}/concourse_creds.yml
fi
