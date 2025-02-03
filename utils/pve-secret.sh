#!/bin/bash

kubectl create secret generic proxmox-csi-plugin --from-file=./config.yaml --dry-run=client -o yaml >proxmox-csi-plugin-secrets.yaml

kubectl create secret generic proxmox-cloud-controller --from-file=./config.yaml --dry-run=client -o yaml >proxmox-cloud-controller-secrets.yaml
