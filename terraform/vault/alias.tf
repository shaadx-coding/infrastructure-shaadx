resource "vault_identity_entity_alias" "shaadx" {
  name = vault_identity_entity.shaadx.name
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.shaadx.id
}
