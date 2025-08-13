# home-ops

![GitHub repo size](https://img.shields.io/github/repo-size/alexrf45/home-ops) [![Static Badge](https://img.shields.io/badge/fr3d.dev-blue?style=plastic&link=https%3A%2F%2Ffr3d.dev)](https://blog.fr3d.dev)

![Static Badge](https://img.shields.io/badge/talos-v1.10.6-orange?style=plastic&logo=Talos&logoColor=%23FF7300) ![Static Badge](https://img.shields.io/badge/k8s-v1.33.0-blue?style=plastic&logo=Kubernetes&logoColor=%23326CE5&logoSize=auto) ![Static Badge](https://img.shields.io/badge/flux-v2.6.4-blue?style=plastic&logo=flux&logoSize=auto&link=https%3A%2F%2Fblog.fr3d.dev) ![Static Badge](https://img.shields.io/badge/terraform-v1.12.2-purple?style=plastic&logo=terraform&color=%237B42BC) ![Static Badge](https://img.shields.io/badge/proxmox-v8.4.1-orange?style=plastic&logo=proxmox&logoSize=auto&link=https%3A%2F%2Fblog.fr3d.dev)

This repository automates the deployment of Kubernetes & Talos Linux on Proxmox with Terraform & Flux.

## Infrastructure Services

| Service            | Status      | Environment        | Notes                               |
| ------------------ | ----------- | ------------------ | ----------------------------------- |
| Cert-Manager       | Active      | All                | SSL certificate management          |
| Cilium             | Active      | All                | CNI networking                      |
| Cloudflare         | Coming Soon | N/A                | DNS and security                    |
| External-Secrets   | Active      | All                | Secret management                   |
| Grafana            | Active      | Dev                | Monitoring dashboards               |
| Prometheus         | Active      | Dev                | Metrics collection                  |
| Longhorn           | Testing     | Testing,Dev        | Distributed storage                 |
| Tailscale          | Active      | Testing, Dev, Prod | VPN mesh networking                 |
| OnePassword        | Active      | All                | Password management                 |
| BarmanCloud Plugin | Active      | Dev                | PostgreSQL backup for CloudnativePG |
| CloudnativePG      | Active      | Dev                | PostgreSQL operator                 |

### Removed Services

| Service                | Reason                     |
| ---------------------- | -------------------------- |
| Argo-CD                | Replaced with Flux         |
| External-DNS           | No longer needed           |
| Pi-Hole                | Consolidated DNS solution  |
| Local-Path Provisioner | Removed in dev environment |
| CSI-Driver-SMB         | Removed in dev environment |

## Applications

| Application   | Status | Environment | URL                                    |
| ------------- | ------ | ----------- | -------------------------------------- |
| Personal Blog | Active | Prod        | [blog.fr3d.dev](https://blog.fr3d.dev) |
| Wallabag      | Active | Dev         | Read-later service                     |

## Updates & Changelog

| Date       | Update                                                                                                 |
| ---------- | ------------------------------------------------------------------------------------------------------ |
| 2025-07-26 | Testing cluster added for CloudnativePG database disaster recovery                                     |
| 2025-07-26 | Disaster recovery testing successful. Planning NAS investment and local block storage backups for 2026 |
| 2025-05-11 | Personal blog launched at blog.fr3d.dev                                                                |
| 2025-05-05 | Terraform code stabilized, production environment scaled successfully                                  |
| 2025-02-02 | Terraform code refactoring for optimized Talos Linux bootstrap process                                 |

## Architecture

This homelab setup provides:

- **Infrastructure as Code**: Terraform for Proxmox VM provisioning
- **GitOps**: Flux for Kubernetes application deployment
- **Consolidated Networking**: Cilium for ingress & network security
- **Monitoring**: Prometheus + Grafana stack
- **Storage**: Longhorn for distributed persistent volumes
- **Security**: Cert-Manager for TLS, External-Secrets & OnePassword for secret management
