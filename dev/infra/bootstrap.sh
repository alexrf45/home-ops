#!/bin/bash

set -e

touch ./module-testing/patches/cilium-cni-patch.yaml

terraform init -backend-config="remote.tfbackend" -upgrade

terraform plan

terraform apply --auto-approve

terraform output

#cp ./module-testing/patches/cilium-cni-patch.yaml patch.yaml

talosctl patch mc -n 10.3.3.60 -p @./module-testing/patches/cilium-cni-patch.yaml --talosconfig=./module-testing/configs/talosconfig

talosctl patch mc -n 10.3.3.60 -p @./patches/patch.yaml --talosconfig=./module-testing/configs/talosconfig
#talosctl bootstrap -n 10.3.3.60 --endpoints 10.3.3.60 --talosconfig=./outputs/talosconfig
#talosctl patch mc -n 10.3.3.60 -p @patch.yaml --talosconfig=./outputs/talosconfig
#adjust depending on number of nodes
#
kubectl label node fr3d-worker-0 fr3d-worker-1 node-role.kubernetes.io/worker=true --kubeconfig=./module-testing/configs/kubeconfig
