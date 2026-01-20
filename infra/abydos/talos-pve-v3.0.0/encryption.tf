#------------------------------------------------------------------------------
# Encryption Key (for non-TPM encryption)
#------------------------------------------------------------------------------
resource "random_password" "encryption_key" {
  count   = var.encryption.enabled && !var.encryption.tpm_based && var.encryption.static_key == "" ? 1 : 0
  length  = 32
  special = true
}
