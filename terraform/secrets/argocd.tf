#
# Let's create Argocd secrets
#

resource "vault_generic_secret" "k8s-in-cluster_argocd_secret" {
  path = "k8s-in-cluster/argocd/secret"
  data_json = jsonencode({
    ARGOCD_ADMIN_PASSWORD = "FIX ME"
  })
}
