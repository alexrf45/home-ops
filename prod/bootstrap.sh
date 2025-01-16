!#/bin/bash

set -e

terraform init -backend-config="remote.tfbackend" -upgrade

terraform plan

terraform apply --auto-approve

terraform output

#talosctl bootstrap -n 10.3.3.60 --endpoints 10.3.3.60 --talosconfig=./outputs/talosconfig
#talosctl patch mc -n 10.3.3.60 -p @patch.yaml --talosconfig=./outputs/talosconfig
#adjust depending on number of nodes
#
#
