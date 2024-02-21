resource "vault_kubernetes_auth_backend_role" "vault-secret-operator" {
  backend = vault_auth_backend.kubernetes.path
  
  bound_service_account_namespaces = ["vault-secrets-operator"]
  bound_service_account_names      = ["vault-secrets-operator"]

  role_name      = "vault-secrets-operator"
  token_policies = [vault_policy.prod.name]
  token_ttl      = 24 * 60 * 60 # 24h
}
