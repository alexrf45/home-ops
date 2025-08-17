resource "flux_bootstrap_git" "this" {
  version = var.flux_version
  path    = "clusters/${var.cluster.environment}"
}
