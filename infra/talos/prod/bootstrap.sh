#!/bin/bash

set -e

deploy() {
  #terraform init -backend-config="remote.tfbackend" -upgrade -reconfigure

  terraform plan

  terraform apply --auto-approve

  terraform output -raw kubeconfig >"$HOME/.kube/environments/prod"

  terraform output -raw client_configuration >"$HOME/.talos/prod"

  cp ~/.kube/config ~/.kube/config_bk && KUBECONFIG=~/.kube/environments/dev:~/.kube/environments/prod:~/.kube/environments/testing kubectl config view --flatten >~/.kube/config_tmp && mv ~/.kube/config_tmp ~/.kube/config

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
    --branch main \
    --force

}

destroy() {

  terraform destroy

  rm ~/.kube/environments/prod

  rm ~/.talos/prod

  #mv ~/.kube/config_bk ~/.kube/config
}

#deploy
flux-deploy
#destroy
