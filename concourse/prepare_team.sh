
ATC_PASSWORD=$1
ATC_TARGET=$2
PCF_ENV=$3

fly -t aws login -k -c ${ATC_TARGET} -u atc -p ${ATC_PASSWORD}

fly -t aws
