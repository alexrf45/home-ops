resource "kubernetes_secret" "sops_age" {
  depends_on = [
    talos_cluster_kubeconfig.this,
    talos_machine_bootstrap.this,
    time_sleep.wait_until_bootstrap
  ]
  metadata {
    name      = "sops-age"
    namespace = "flux-system"
  }

  data = {
    "flux-staging.agekey" = file("~/.local/flux-staging.agekey")
  }

  type = "Opaque"
}

resource "flux_bootstrap_git" "this" {
  depends_on = [
    talos_cluster_kubeconfig.this,
    talos_machine_bootstrap.this,
    time_sleep.wait_until_bootstrap
  ]
  version = var.flux_version
  path    = "clusters/${var.cluster.environment}"
}
