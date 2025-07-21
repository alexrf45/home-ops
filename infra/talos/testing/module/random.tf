resource "random_id" "example" {
  for_each    = toset(var.nodes)
  byte_length = 4
}

