#!/bin/bash

set -e

terraform init -backend-config="remote.tfbackend" -upgrade

terraform plan

terraform apply --auto-approve

cp ./outputs/talosconfig ~/.talos/prod-config

cp ./outputs/kubeconfig ~/.kube/new_config

cp ~/.kube/config ~/.kube/config_bk && KUBECONFIG=~/.kube/config:~/.kube/new_config kubectl config view --flatten >~/.kube/config_tmp && mv ~/.kube/config_tmp ~/.kube/config

#kubectx admin@prod

#terraform output
#kubectl label node prod-node-3 prod-node-4 prod-node-5 prod-node-6 node-role.kubernetes.io/worker=true

# cat ~/.local/flux-staging.agekey | kubectl create secret generic sops-age \
#   --namespace=flux-system \
#   --from-file=flux-staging.agekey=/dev/stdin
# #
# flux bootstrap git \
#   --cluster-domain=cluster.local \
#   --url=ssh://git@github.com/alexrf45/home-ops.git \
#   --path=clusters/production \
#   --private-key-file=/home/fr3d/.ssh/fr3d \
#   --branch main
