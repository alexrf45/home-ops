resource "random_id" "this" {
  for_each = { for k, v in merge(var.worker_nodes, var.controlplane_nodes)
    : k => v.node
  }
  byte_length = 8
  keepers = {
    node = each.key
  }
}
