#!/bin/bash

set -e

terraform init -backend-config="remote.tfbackend" -upgrade

terraform plan

terraform apply --auto-approve

terraform output

#talosctl bootstrap -n 10.3.3.60 --endpoints 10.3.3.60 --talosconfig=./outputs/talosconfig
talosctl patch mc -n 10.3.3.60 -p @patch.yaml --talosconfig=./outputs/talosconfig
#adjust depending on number of nodes
talosctl apply-config -f outputs/worker.yaml --insecure \
  --nodes 10.3.3.61 --talosconfig=./outputs/talosconfig
#talosctl apply-config -f outputs/controlplane.yaml --insecure \
# --nodes 10.3.3.62 --talosconfig=./outputs/talosconfig
#
kubectl label node node-02 node-03 node-role.kubernetes.io/worker=true
