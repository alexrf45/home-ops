#!/bin/bash

set -e

touch ./patches/cilium-cni-patch.yaml

terraform init -backend-config="remote.tfbackend" -upgrade

terraform plan

terraform apply --auto-approve

terraform output

talosctl patch mc -n 10.3.3.60 -p @./patches/cilium-cni-patch.yaml --talosconfig=./configs/talosconfig

#talosctl patch mc -n 10.3.3.60 -p @./patches/patch.yaml --talosconfig=./configs/talosconfig

talosctl patch mc -n 10.3.3.60 -p @./patches/metrics.yaml --talosconfig=./configs/talosconfig
talosctl patch mc -n 10.3.3.61 -p @./patches/metrics.yaml --talosconfig=./configs/talosconfig
talosctl patch mc -n 10.3.3.62 -p @./patches/metrics.yaml --talosconfig=./configs/talosconfig

kubectl label node fr3d-worker-0 fr3d-worker-1 node-role.kubernetes.io/worker=true --kubeconfig=./configs/kubeconfig

kubectl delete daemonset -n kube-system kube-flannel --kubeconfig=./configs/kubeconfig
kubectl delete daemonset -n kube-system kube-proxy --kubeconfig=./configs/kubeconfig
kubectl delete cm kube-flannel-cfg -n kube-system --kubeconfig=./configs/kubeconfig

git clone git@github.com:alexrf45/home-ops-flux.git ~/projects/home-ops-flux

cp configs/talosconfig ~/.talos/config

cp configs/kubeconfig ~/.kube/config

k9s
