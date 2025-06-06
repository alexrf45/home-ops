# home-ops

![GitHub repo size](https://img.shields.io/github/repo-size/alexrf45/home-ops) [![Static Badge](https://img.shields.io/badge/fr3d.dev-blue?style=plastic&link=https%3A%2F%2Ffr3d.dev)](https://fr3d.dev)

![Static Badge](https://img.shields.io/badge/talos-v1.10.0-orange?style=plastic&logo=Talos&logoColor=%23FF7300) ![Static Badge](https://img.shields.io/badge/k8s-v1.33.0-blue?style=plastic&logo=Kubernetes&logoColor=%23326CE5&logoSize=auto) ![Static Badge](https://img.shields.io/badge/flux-v2.5.1-blue?style=plastic&logo=flux&logoSize=auto&link=https%3A%2F%2Fhomelab.fr3d.dev) ![Static Badge](https://img.shields.io/badge/terraform-v1.11.4-purple?style=plastic&logo=terraform&color=%237B42BC) ![Static Badge](https://img.shields.io/badge/proxmox-v8.4.1-orange?style=plastic&logo=proxmox&logoSize=auto&link=https%3A%2F%2Fhomelab.fr3d.dev)

This repository automates the deployment of Kubernetes & Talos Linux on Proxmox with Terraform & Flux

## Services

- [ ] Argo-CD (Removed in dev)
- [ ] Cert-Manager
- [ ] Cillium
- [ ] Cloudflare (coming soon)
- [ ] External-Secrets
- [ ] External-DNS
- [ ] Grafana
- [ ] Pi-Hole
- [ ] Prometheus
- [ ] Local-Path Provisioner
- [ ] CSI-Driver-SMB
- [ ] Longhorn (Removed)
- [ ] More to come!

## Updates

**2025-02-02** The terraform code is subject to change as I find
new ways to optimize the talos linux bootstrap process

2025-05-05 TF code is stable, prod scaled well

2025-05-11 My personal blog is up and running at blog.fr3d.dev. 
 - Cloudflare pages site at fr3d.dev will be removed soon
