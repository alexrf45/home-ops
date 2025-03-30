#!/bin/bash

set -e

ansible-playbook -i inventory/hosts.yaml -K playbooks/auditing-k3s.yaml

ansible-playbook -i inventory/hosts.yaml -e @secrets.yaml --ask-vault-password -K playbooks/k3s-ha.yaml

scp home-4:/etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"

sed -ie s/127.0.0.1/10.3.3.6/g "$HOME/.kube/config"

kubectl create namespace flux-system

cat ~/.local/flux-staging.agekey | kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=flux-staging.agekey=/dev/stdin

flux bootstrap git \
  --cluster-domain=cluster.local \
  --url=ssh://git@github.com/alexrf45/home-ops.git \
  --path=flux/fr3d \
  --private-key-file=/home/fr3d/.ssh/fr3d \
  --branch main

#kubectl label node home-0 home-1 home-3 node-role.kubernetes.io/worker=true
