#!/bin/bash -exu

function main() {
  export CURR_DIR=$(pwd)
  export OPSMGR_VERSION=$(cat ./pivnet-opsmgr/metadata.json | jq '.Release.Version' | sed -e 's/^"//' -e 's/"$//')

  export OPSMAN_NAME=OpsManager-${OPSMGR_VERSION}-$(date +"%Y%m%d%H%S")

  echo '
  {
    "DiskProvisioning":"thin",
    "IPAllocationPolicy":"dhcpPolicy",
    "IPProtocol":"IPv4",
    "NetworkMapping": [{
      "Name":"Network 1",
      "Network":"${OPSMAN_NETWORK}"
    }],
    "PropertyMapping":[
      {"Key":"ip0","Value":"${OPSMAN_IP}"},
      {"Key":"netmask0","Value":"${NETMASK}"},
      {"Key":"gateway","Value":"${GATEWAY}"},
      {"Key":"DNS","Value":"${DNS}"},
      {"Key":"ntp_servers","Value":"${NTP}"},
      {"Key":"admin_password","Value":"${OPSMAN_ADMIN_PASSWORD}"}
    ],
    "PowerOn":false,
    "InjectOvfEnv":false,
    "WaitForIP":false
  }' > ./opsman_settings.json

  echo "Importing OVA of new OpsMgr VM..."
  govc import.ova --options=opsman_settings.json --name=${OPSMAN_NAME} -k=true --folder=/${GOVC_DATACENTER}/vm/${OPSMAN_VM_FOLDER} ${CURR_DIR}/pivnet-opsmgr/pcf-vsphere-1.9.2.ova

  echo "Importing OVA of new OpsMgr VM..."
  govc vm.change -c=2 -vm /${GOVC_DATACENTER}/vm/${OPSMAN_VM_FOLDER}/${OPSMAN_NAME}

  govc vm.power -off=true -vm.ip=${OPSMAN_IP}

  govc vm.power -on=true /${GOVC_DATACENTER}/vm/${OPSMAN_VM_FOLDER}/${OPSMAN_NAME}
}

echo "Running deploy of OpsMgr VM task..."
main "${PWD}"