<div align="center">

<img src="https://avatars.githubusercontent.com/u/61287648?s=200&v=4" align="center" width="144px" height="144px" alt="kubernetes"/>

## home-ops

</div>
<div align="center">

![GitHub repo size](https://img.shields.io/github/repo-size/alexrf45/home-ops) [![Static Badge](https://img.shields.io/badge/fr3d.dev-blue?style=plastic&link=https%3A%2F%2Ffr3d.dev)](https://blog.fr3d.dev)
![Static Badge](https://img.shields.io/badge/talos-v1.10.6-orange?style=plastic&logo=Talos&logoColor=%23FF7300) ![Static Badge](https://img.shields.io/badge/k8s-v1.33.4-blue?style=plastic&logo=Kubernetes&logoColor=%23326CE5&logoSize=auto) ![Static Badge](https://img.shields.io/badge/flux-v2.6.4-blue?style=plastic&logo=flux&logoSize=auto&link=https%3A%2F%2Fblog.fr3d.dev) ![Static Badge](https://img.shields.io/badge/terraform-v1.13.3-purple?style=plastic&logo=terraform&color=%237B42BC) ![Static Badge](https://img.shields.io/badge/proxmox-v8.4.1-orange?style=plastic&logo=proxmox&logoSize=auto&link=https%3A%2F%2Fblog.fr3d.dev)

</div>
This repository automates the deployment of Kubernetes & Talos Linux on Proxmox with Terraform & Flux.

## Applications

| Application | Status | Environment | URL                |
| ----------- | ------ | ----------- | ------------------ |
| Wallabag    | Active | Prod        | Read-later service |
| Homepage    | Active | Dev, Prod   | Application Portal |
| IT-Tools    | Active | Dev, Prod   | Useful tools       |

## Architecture

- **Infrastructure as Code**: Terraform for Proxmox VM provisioning
- **GitOps**: Flux for Kubernetes application deployment
- **Consolidated Networking**: Cilium for ingress & network security
- **DNS:** CoreDNS, External DNS with Ubiquiti Controller
- **Storage:** Local Path Provisioner
- **Database:** MariaDB Operator, CloudnativePG
- **Monitoring**: Prometheus + Grafana stack
- **Security**: Cert-Manager for TLS, External-Secrets & OnePassword for secret management
- **Configuration Management:** Renovate, Kyverno (Dev)
- **Remote Access:** Tailscale, Cloudflare
