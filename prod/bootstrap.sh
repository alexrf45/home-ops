!#/bin/bash

talosctl bootstrap -n 10.3.3.60 --endpoints 10.3.3.60 --talosconfig=./outputs/talosconfig

talosctl patch mc -n 10.3.3.60 --endpoints 10.3.3.60 @patch.yaml --talosconfig=./outputs/talosconfig
#adjust based on HA requirements

talosctl apply-config --insecure \
  --nodes 10.3.3.61 --talosconfig=./outputs/talosconfig

talosctl apply-config --insecure \
  --nodes 10.3.3.62 --talosconfig=./outputs/talosconfig

talosctl apply-config --insecure \
  --nodes 10.3.3.61 --talosconfig=./outputs/talosconfig

#adjust depending on number of nodes
talosctl apply-config -f worker_config.yaml --insecure \
  --nodes 10.3.3.63 --talosconfig=./outputs/talosconfig

talosctl apply-config -f worker_config.yaml --insecure \
  --nodes 10.3.3.64 --talosconfig=./outputs/talosconfig

talosctl apply-config -f worker_config.yaml --insecure \
  --nodes 10.3.3.65 --talosconfig=./outputs/talosconfig

talosctl apply-config -f worker_config.yaml --insecure \
  --nodes 10.3.3.65 --talosconfig=./outputs/talosconfig

#tf uses localfiles to save these but you can alos manually grab them with
# the commands below
#terraform output control_plane_config >./outputs/controlplane.yaml

#terraform output worker_config >./outputs/worker.yaml
