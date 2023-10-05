resource "vault_identity_group" "admin" {
  name = vault_policy.admin.name
  type = "internal"
  
  policies = [
    vault_policy.admin.name
  ]
  
  member_entity_ids = [
    vault_identity_entity.shaadx.id
  ]

  metadata = {
    version = "2"
  }
}

resource "vault_identity_group" "users" {
  name = "users"
  type = "internal"
  
  member_entity_ids = [
    vault_identity_entity.shaadx.id
  ]
  
  policies = [
    vault_policy.user.name
  ]
  
  metadata = {
    version = "2"
  }
}
