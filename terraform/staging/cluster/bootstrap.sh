#!/bin/bash

set -e

terraform init -backend-config="remote.tfbackend" -upgrade

terraform plan

terraform apply --auto-approve

cp ./outputs/talosconfig ~/.talos/staging

cp ./outputs/kubeconfig ~/.kube/new_config

kubectl label node staging-node-3 node-role.kubernetes.io/worker=true
#

cat ~/.local/flux-staging.agekey | kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=flux-staging.agekey=/dev/stdin

flux bootstrap git \
  --cluster-domain=cluster.local \
  --url=ssh://git@github.com/alexrf45/home-ops.git \
  --path=clusters/staging \
  --private-key-file=/home/fr3d/.ssh/fr3d \
  --branch main
