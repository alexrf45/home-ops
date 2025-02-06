#!/bin/bash

kubectl create secret generic proxmox-csi-plugin -n csi-proxmox --from-file=./config.yaml \
  --dry-run=client -o yaml >../infrastructure/controllers/base/proxmox-csi/proxmox-csi-plugin-secrets.yaml

kubectl create secret generic proxmox-cloud-controller-manager -n csi-proxmox --from-file=./config.yaml \
  --dry-run=client -o yaml >../infrastructure/controllers/base/proxmox-csi/proxmox-cloud-controller-secrets.yaml

sops --age="$AGEKEY" \
  --encrypt --encrypted-regex '^(data|stringData)$' --in-place ../infrastructure/controllers/base/proxmox-csi/proxmox-csi-plugin-secrets.yaml

sops --age="$AGEKEY" \
  --encrypt --encrypted-regex '^(data|stringData)$' --in-place ../infrastructure/controllers/base/proxmox-csi/proxmox-cloud-controller-secrets.yaml
