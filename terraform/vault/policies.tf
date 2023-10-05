resource "vault_policy" "admin" {
  name = "admin"
  policy = <<EOT
    path "*" {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
    EOT
}

resource "vault_policy" "prod" {
  name = "prod"
  policy = <<EOT
    path "${vault_mount.prod.path}/*" {
      capabilities = ["read"]
    }
    EOT
}

resource "vault_policy" "user" {
  name = "user"
  policy = <<EOT
    path "auth/${vault_auth_backend.userpass.path}/users/{{identity.entity.aliases.${vault_auth_backend.userpass.accessor}.name}}" {
      capabilities = [ "update" ]
      allowed_parameters = {
        "password" = []
      }
    }
    EOT
}
