
# Specify which type of background auth is needed
resource "vault_auth_backend" "this" {
  type = "approle" # Allows machines and apps to authenticate with a specific role
  path = "in-cluster"
}

# Define the policy of access to those secrets
resource "vault_policy" "this" {
  name = "in-cluster-vault-secrets-operator"
  
  policy = <<-EOP
    path "${vault_auth_backend.this.path}/*" {
      capabilities = ["read"]  
  }
  EOP
}

# Let's now create the roles
resource "vault_approle_auth_backend_role" "this" {
  backend = vault_auth_backend.this.path
  role_name = "vault-secrets-operator"
  token_policies = [vault_policy.this.name]
  token_ttl = 24 * 60 * 60 # This give the token a 24h time to live
}

# Setting up the role for the secret id
resource "vault_approle_auth_backend_role_secret_id" "this" {
  backend = vault_auth_backend.this.path
  role_name = vault_approle_auth_backend_role.this.role_name
}

# Create the ressource that will allow us to inject secrets directly into kube
resource "kubernetes_secret" "this" {
  metadata {
    name = "vault-approle"
    namespace = "vault-secrets-operator"
  }

  # Creating the data
  data = {
    VAULT_ROLE_ID = vault_approle_auth_backend_role.this.role_id
    VAULT_SECRET_ID = vault_approle_auth_backend_role_secret_id.this.secret_id
    VAULT_TOKEN_MAX_TTL = vault_approle_auth_backend_role.this.token_ttl
  }

  # Setting up the data type to Opaque
  type = "Opaque"
}
