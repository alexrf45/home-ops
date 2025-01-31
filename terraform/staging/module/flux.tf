# resource "github_repository" "this" {
#   depends_on  = [time_sleep.wait_until_bootstrap]
#   count       = var.create_repo
#   name        = var.github_repository.name
#   description = var.github_repository.description
#   visibility  = var.github_repository.visibility
#   auto_init   = true
# }

# secrets management is a bit weird as I have no way to decrypt the yaml before flux can create
# the resources on the cluster. most articles show the manual way of creating a secret
# trying inline manifests. cilium needs to be installed inline instead of flux

# resource "flux_bootstrap_git" "this" {
#   depends_on = [
#     talos_machine_bootstrap.this,
#     time_sleep.wait_until_bootstrap,
#     talos_cluster_kubeconfig.this
#   ]
#   components_extra   = var.flux_extras
#   embedded_manifests = true
#   path               = format("clusters/%s", var.cluster.env)
#   interval           = "1m0s"
#
# }
