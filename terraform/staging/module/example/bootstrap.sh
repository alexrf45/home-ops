#!/bin/bash

set -e

#replace with repo created on the previous apply
sudo rm -r ~/projects/home-ops-flux/

#this ensures the module can pick up the file and render from the template
touch ./patches/cilium-cni-patch.yaml

terraform init -backend-config="remote.tfbackend" -upgrade

terraform plan

terraform apply --auto-approve

terraform output

#cp ./module-testing/patches/cilium-cni-patch.yaml patch.yaml

#this can be modified based on where the patch file gets created. currently it is created in
# in the root directory
#currently the render into a config patch during machine apply does not work. this my workaround for now
talosctl patch mc -n 10.3.3.60 -p @./patches/cilium-cni-patch.yaml --talosconfig=./configs/talosconfig

#replace with other desired patches
talosctl patch mc -n 10.3.3.60 -p @./patches/patch.yaml --talosconfig=./configs/talosconfig
#talosctl bootstrap -n 10.3.3.60 --endpoints 10.3.3.60 --talosconfig=./outputs/talosconfig
#talosctl patch mc -n 10.3.3.60 -p @patch.yaml --talosconfig=./outputs/talosconfig
#adjust depending on number of nodes
#
kubectl label node fr3d-worker-0 fr3d-worker-1 node-role.kubernetes.io/worker=true --kubeconfig=./configs/kubeconfig

#replace with the repo you specified
git clone git@github.com:alexrf45/home-ops-flux.git ~/projects/home-ops-flux
