#
# Let's create Argocd secrets
#

# Set up the random password ressource to create our secret
resource "random_password" "k8s-in-cluster_argocd_secret" {
  count = 1
  length = 64
  special = true
}

resource "vault_generic_secret" "k8s-in-cluster_argocd_secret" {
  path = "k8s-in-cluster/argocd/secret"
  data_json = jsonencode({
    ARGOCD_ADMIN_PASSWORD = random_password.k8s-in-cluster_argocd_secret.result
  })
}
