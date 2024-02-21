resource "vault_kubernetes_secret_backend" "config" {
  path                      = "kubernetes"
  description               = "Kubernetes production backend"
  default_lease_ttl_seconds = 43200
  max_lease_ttl_seconds     = 86400
}
