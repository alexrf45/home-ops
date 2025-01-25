#!/bin/bash

set -e

terraform init -backend-config="remote.tfbackend" -upgrade

terraform plan

terraform apply --auto-approve

cp ./outputs/talosconfig ~/.talos/config

cp ./outputs/kubeconfig ~/.kube/config

#terraform output

kubectl label node staging-worker-0 staging-worker-1 node-role.kubernetes.io/worker=true

kubectl create namespace flux-system

kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=~/.local/flux-staging.agekey=/dev/stdin

flux bootstrap git --url=ssh://git@github.com/alexrf45/home-ops.git --path=clusters/staging --private-key-file=/home/fr3d/.ssh/fr3d --branch dev
