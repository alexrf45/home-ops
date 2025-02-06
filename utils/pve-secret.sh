#!/bin/bash

kubectl create secret generic proxmox-csi-plugin --from-file=./pve-csi-config.yaml \
  --dry-run=client -o yaml >../infrastructure/controllers/base/proxmox-csi/proxmox-csi-plugin-secrets.yaml

kubectl create secret generic proxmox-cloud-controller --from-file=./pve-cloud-config.yaml \
  --dry-run=client -o yaml >../infrastructure/controllers/base/proxmox-csi/proxmox-cloud-controller-secrets.yaml
