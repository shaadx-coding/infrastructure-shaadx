resource "vault_identity_oidc_assignment" "admin" {
  name = "admin"
  group_ids = [
    vault_identity_group.admin.id
  ]
}

# Let's create our first resource for argocd and more
resource "vault_identity_oidc_client" "admin" {
  name = "admin"

  redirect_uris = [
    "https://argocd.shaadx.com/auth/callback"
  ]
  
  assignments = [
    vault_identity_oidc_assignment.admin.name
  ]
  
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

# Let's set up vault as the provider
resource "vault_identity_oidc_provider" "admin" {
  name          = "admin"
  https_enabled = true
  issuer_host   = "vault.shaadx.com"
  
  allowed_client_ids = [
    vault_identity_oidc_client.admin.client_id
  ]

  scopes_supported = [
    vault_identity_oidc_scope.roles.name
  ]
}

resource "vault_identity_oidc_provider" "default" {
  name          = "default"
  https_enabled = true
  issuer_host   = "vault.shaadx.com"
  
  allowed_client_ids = [
    # For the moment nothing but in the futur for all my new services
  ]

  scopes_supported = [
    vault_identity_oidc_scope.profile.name,
    vault_identity_oidc_scope.email.name,
    vault_identity_oidc_scope.roles.name
  ]
}

# Let's define the scopes used earlier
resource "vault_identity_oidc_scope" "profile" {
  name      = "profile"
  template  = <<EOT
  {
    "name": {{ identity.entity.metadata.full_name }},
    "family_name": {{ identity.entity.metadata.family_name }},
    "given_name": {{ identity.entity.metadata.given_name }},
    "middle_name": {{ identity.entity.metadata.middle_name }},
    "nickname": {{ identity.entity.metadata.name }},
    "preferred_username": {{ identity.entity.metadata.nickname }},
    "updated_at": {{ time.now }}
  }
  EOT
  description = "Default profile for openid scope"
}

resource "vault_identity_oidc_scope" "email" {
  name      = "email"
  template  = <<EOT
  {
    "email": {{ identity.entity.metadata.email }},
    "email_verified": true
  }
  EOT
  description = "Default email for openid scope"
}

resource "vault_identity_oidc_scope" "roles" {
  name      = "roles"
  template  = <<EOT
  {
    "roles": {{ identity.entity.groups.names }}
  }
  EOT
  description = "User roles"
}
