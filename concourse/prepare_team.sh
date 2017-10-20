set -e

#Needs Pass PCF ENV, TEAM USERNAME, TEAM PASSWORD

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TSTATE_FILE="${DIR}/../terraform.tfstate"

export VAULT_IP=$(bosh-cli int ./director.yml --path /vault_static_ips/0)
export VAULT_ADDR=https://${VAULT_IP}:8200
export VAULT_SKIP_VERIFY=true
export ATC_PASSWORD=$(bosh-cli int ${BOSH_WORK_DIR}/concourse_creds.yml --path /admin_password)

ATC_URL=$(terraform state show -state ${TSTATE_FILE} aws_elb.concourse | grep dns_name | awk '{print $3}')
ATC_TARGET="https://${ATC_URL}"

wget --no-check-certificate -O fly "https://${ATC_URL}/api/v1/cli?arch=amd64&platform=linux" && chmod +x fly

./fly -t aws login -k -c ${ATC_TARGET} -u atc -p ${ATC_PASSWORD}
./fly -t aws sync

./fly -t aws set-team --team-name ${PCF_ENV} \
    --basic-auth-username ${TEAM_USERNAME} \
    --basic-auth-password ${TEAM_PASSWORD} \
    --non-interactive

for n in db_master_password db_app_usage_service_password db_autoscale_password db_diego_password db_notifications_password db_routing_password db_uaa_password db_ccdb_password db_accountdb_password db_networkpolicyserverdb_password db_nfsvolumedb_password db_silk_password db_locket_password
  do
  pass=$(openssl rand -base64 20)
  vault write concourse/${PCF_ENV}/${n} value=${pass}
done

vault write concourse/${PCF_ENV}/pivnet_token value=${PIVNET_TOKEN}
vault write concourse/${PCF_ENV}/aws_access_key value=${AWS_ACCESS_KEY}
vault write concourse/${PCF_ENV}/aws_secret_key value=${AWS_SECRET_KEY}
vault write concourse/${PCF_ENV}/opsman_password value=${OPSMAN_PASSWORD}
