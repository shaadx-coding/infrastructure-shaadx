resource "vault_mount" "prod" {
  path        = "prod"
  type        = "kv"
  options     = { version = "2" }
  description = "Production secrets"
}
