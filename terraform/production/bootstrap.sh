#!/bin/bash

set -e

terraform init -backend-config="remote.tfbackend" -upgrade

terraform plan

terraform apply --auto-approve

cp ./outputs/talosconfig ~/.talos/prod-config

cp ./outputs/kubeconfig ~/.kube/prod-config

#terraform output

# kubectl label node prod-node-2 node-role.kubernetes.io/worker=true
#
# kubectl label node prod-node-1 type=node
# kubectl label node prod-node-2 type=node
kubectl label node prod-node-3 type=node
# kubectl label node prod-node-4 type=node

cat ~/.local/flux-production.agekey | kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=flux-production.agekey=/dev/stdin
#
flux bootstrap git \
  --cluster-domain=cluster.local \
  --url=ssh://git@github.com/alexrf45/home-ops.git \
  --path=clusters/production \
  --private-key-file=/home/fr3d/.ssh/fr3d \
  --branch main
