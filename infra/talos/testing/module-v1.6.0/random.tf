resource "random_id" "example" {
  for_each    = { for k, v in var.nodes : k => v.node }
  byte_length = 4
}
