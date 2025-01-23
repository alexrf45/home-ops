#!/bin/bash

set -e

terraform init -backend-config="remote.tfbackend" -upgrade

terraform plan

terraform apply --auto-approve

terraform output

kubectl apply -f cilium.yaml

kubectl label node staging-worker-0 staging-worker-1 node-role.kubernetes.io/worker=true --kubeconfig=./configs/kubeconfig

#git clone git@github.com:alexrf45/home-ops-flux.git ~/projects/home-ops-flux

cp ./outputs/talosconfig ~/.talos/config

cp ./outputs/kubeconfig ~/.kube/config

flux bootstrap git --url=ssh://git@github.com/alexrf45/home-ops.git --path=clusters/staging --private-key-file=/home/fr3d//.ssh/fr3d --branch dev
