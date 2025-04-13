#!/bin/bash

set -e

deploy() {
  terraform init -backend-config="remote.tfbackend" -upgrade

  terraform plan

  terraform apply --auto-approve

  cp ./outputs/talosconfig ~/.talos/prod

  cp ./outputs/kubeconfig ~/.kube/prod

  cp ~/.kube/config ~/.kube/config_bk && KUBECONFIG=~/.kube/dev:~/.kube/prod kubectl config view --flatten >~/.kube/config_tmp && mv ~/.kube/config_tmp ~/.kube/config

  kubectx admin@prod

  kubectl label node prod-node-3 prod-node-4 prod-node-5 prod-node-6 prod-node-7 node-role.kubernetes.io/worker=true

}

flux-deploy() {

  cat ~/.local/flux-staging.agekey | kubectl create secret generic sops-age \
    --namespace=flux-system \
    --from-file=flux-staging.agekey=/dev/stdin

  flux bootstrap git \
    --cluster-domain=cluster.local \
    --url=ssh://git@github.com/alexrf45/home-ops.git \
    --path=clusters/prod \
    --private-key-file=/home/fr3d/.ssh/fr3d \
    --branch main

}

destroy() {

  terraform destroy

  rm ~/.kube/prod

  rm ~/.talos/prod

  mv ~/.kube/config_bk ~/.kube/config
}

#deploy

flux-deploy
#destroy
