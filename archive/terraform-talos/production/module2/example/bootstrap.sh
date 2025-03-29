#!/bin/bash

set -e

terraform init -backend-config="remote.tfbackend" -upgrade

terraform plan

terraform apply --auto-approve

terraform output

cp ./outputs/talosconfig ~/.talos/config

cp ./outputs/kubeconfig ~/.kube/config

#will add to template file in rc-3
#kubectl label node fr3d-worker-0 fr3d-worker-1 node-role.kubernetes.io/worker=true --kubeconfig=./configs/kubeconfig
