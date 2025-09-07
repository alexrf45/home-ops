# home-ops

![GitHub repo size](https://img.shields.io/github/repo-size/alexrf45/home-ops) [![Static Badge](https://img.shields.io/badge/fr3d.dev-blue?style=plastic&link=https%3A%2F%2Ffr3d.dev)](https://blog.fr3d.dev)

![Static Badge](https://img.shields.io/badge/talos-v1.10.6-orange?style=plastic&logo=Talos&logoColor=%23FF7300) ![Static Badge](https://img.shields.io/badge/k8s-v1.33.0-blue?style=plastic&logo=Kubernetes&logoColor=%23326CE5&logoSize=auto) ![Static Badge](https://img.shields.io/badge/flux-v2.6.4-blue?style=plastic&logo=flux&logoSize=auto&link=https%3A%2F%2Fblog.fr3d.dev) ![Static Badge](https://img.shields.io/badge/terraform-v1.12.2-purple?style=plastic&logo=terraform&color=%237B42BC) ![Static Badge](https://img.shields.io/badge/proxmox-v8.4.1-orange?style=plastic&logo=proxmox&logoSize=auto&link=https%3A%2F%2Fblog.fr3d.dev)

This repository automates the deployment of Kubernetes & Talos Linux on Proxmox with Terraform & Flux.

## Applications

| Application | Status | Environment | URL                |
| ----------- | ------ | ----------- | ------------------ |
| Wallabag    | Active | Prod        | Read-later service |

## Architecture

This homelab setup provides:

- **Infrastructure as Code**: Terraform for Proxmox VM provisioning
- **GitOps**: Flux for Kubernetes application deployment
- **Consolidated Networking**: Cilium for ingress & network security
- **Monitoring**: Prometheus + Grafana stack
- **Security**: Cert-Manager for TLS, External-Secrets & OnePassword for secret management
