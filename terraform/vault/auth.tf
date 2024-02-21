resource "vault_auth_backend" "userpass" {
  type = "userpass"
  tune {
    listing_visibility = "unauth"
  }
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend = vault_auth_backend.kubernetes.path
  kubernetes_host = "127.0.0.1:6443"
}
