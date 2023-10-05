# Let's handle everything related to the certificate authority

resource "tls_private_key" "ca" {
  count = 1
  
  algorithm = "RSA"
  ecdsa_curve = "P384"
  rsa_bits = "2048"

}

resource "tls_self_signed_cert" "ca" {
  count = 1
  
  private_key_pem = tls_private_key.ca.0.private_key_pem
  is_ca_certificate = true
  validity_period_hours = tostring(24 * 365)

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature"
  ]

  subject {
    organization = "shaadx.com"
    common_name = "shaadx.com"
    country = "FR"
  }
}

# Let's handle the certificate authority
# Let's also set my vault address as env variable

locals {
  vault_addr = "vault.shaadx.com"
}

resource "tls_private_key" "vault_private_key" {
  count = 1
 
  algorithm = "RSA"
  ecdsa_curve = "P384"
  rsa_bits = "2048"

}

resource "tls_cert_request" "vault_cert_request" {
  count = 1
  
  private_key_pem = tls_private_key.vault_private_key.0.private_key_pem
  
  dns_names = [
    locals.vault_addr,
    "vault.vault.svc",
    "vault.vault",
  ]
  
  subject {
    common_name = "HashiCorp Vault Certificate"
    organization = "HashiCorp Vault Certificate"
  }
}

resource "tls_locally_signed_cert" "vault_signed_certificate" {
  count = 1
  
  cert_request_pem = tls_cert_request.vault_private_key.0.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.0.private_key_pem
  ca_cert_pem = tls_self_signed_cert.ca.0.cert_pem

  validity_period_hours = 24 * 365

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
}
