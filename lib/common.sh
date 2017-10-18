#!/bin/bash

function check_argument() {
  arg=$1
  if [[ ${arg} != "vsphere" && ${arg} != "aws" && ${arg} != "gcp" && ${arg} != "azure" ]]
  then
    echo "[ERROR] : The support IAAS are vsphere, aws, gcp and azure"
    exit 1
  fi
}
