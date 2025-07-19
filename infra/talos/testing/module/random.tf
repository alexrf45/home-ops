# random.tf
resource "random_id" "cluster" {
  byte_length = 5
}
