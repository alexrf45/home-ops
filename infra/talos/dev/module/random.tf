# resource "random_id" "example" {
#   for_each    = toset(var.nodes)
#   byte_length = 4
# }

resource "random_id" "example" {
  for_each    = { for k, v in var.nodes : k => v.node }
  byte_length = 4
}
