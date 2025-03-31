#!/bin/bash

set -e

deploy() {
  terraform init -backend-config="remote.tfbackend" -upgrade

  terraform plan

  terraform apply --auto-approve

  cp ./outputs/talosconfig ~/.talos/dev

  cp ./outputs/kubeconfig ~/.kube/dev

  cp ./outputs/kubeconfig ~/.kube/config

  #cp ~/.kube/config ~/.kube/config_bk && KUBECONFIG=~/.kube/dev:~/.kube/prod kubectl config view --flatten >~/.kube/config_tmp && mv ~/.kube/config_tmp ~/.kube/config

  #kubectx admin@prod

  #terraform output
  kubectl label node dev-node-1 dev-node-2 node-role.kubernetes.io/worker=true

}

flux-deploy() {

  cat ~/.local/flux-staging.agekey | kubectl create secret generic sops-age \
    --namespace=flux-system \
    --from-file=flux-staging.agekey=/dev/stdin
  #
  flux bootstrap git \
    --cluster-domain=cluster.local \
    --url=ssh://git@github.com/alexrf45/home-ops.git \
    --path=clusters/dev \
    --private-key-file=/home/fr3d/.ssh/fr3d \
    --branch main \
    --force

}

destroy() {

  terraform destroy

  rm ~/.kube/dev

  rm ~/.talos/dev

  mv ~/.kube/config_bk ~/.kube/config
}

flux-deploy
