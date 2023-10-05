# Let's create the kubernetes resources
# needed for the deployment
resource "kubernetes_namespace" "vault" {
  count = 1

  metadata = {
    name = "vault"  
  }
}

resource "kubernetes_secret" "tls" {
  count = length(kubernetes_namespace.vault) # Create the secret only if the namespace exists
  
  type = "kubernetes.io/tls"
  
  metadata = {
    name = "tls-server"
    namespace = kubernetes_namespace.vault.0.metadata.0.name
  }
  
  data = {
    "tls.crt" = tls_locally_signed_cert.vault_signed_certificate.0.cert_pem
    "tls.key" = tls_private_key.vault_private_key.0.private_key_pem
  }
}

resource "kubernetes_secret" "tls_ca" {

  count = length(kubernetes_namespace.vault)

  metadata {
    name      = "ca"
    namespace = kubernetes_namespace.vault.0.metadata.0.name
  }

  data = {
    "ca.pem" = tls_self_signed_cert.ca.0.cert_pem
  }
}

resource "kubernetes_service_account" "vault" {

  count = length(kubernetes_namespace.vault)

  metadata {
    name      = "vault"
    namespace = kubernetes_namespace.vault.0.metadata.0.name
  }
}

# Let's handle here the deployment of vault

resource "helm_release" "vault" {
  
    # Here we make sure that the dependency are already created before deploying
    depends_on = [
      kubernetes_service_account.vault,
      kubernetes_secret.tls,
      kubernetes_secret.tls_ca,
    ]

    count = length(kubernetes_namespace.vault)

    name = "vault"
    repository = "https://helm.releases.hashicorp.com/"
    chart = "vault"
    namespace = kubernetes_namespace.vault.0.metadata.0.name

    # Let's create the value for the helm chart
    values = [yamlencode({
      global = { tlsDisabled = false }

      injector = { enabled = true }

      server = {
        serviceAccount = {
          create = false
          name = kubernetes_service_account.vault.0.metadata.0.name
        }

        dataStorage = {
          size = "20Gi"
        }

        service = {
          enabled = true
          type = "ClusterIP"
        }

        standalone = {
          enabled = true

          config = <<EOF
          ui = true
          api_addr = "${locals.vault_addr}"

          listener "tcp" {
            address         = "[::]:8200"
            cluster_address = "[::]:8201"

            tls_disable   = false
            tls_cert_file = "/vault/userconfig/${kubernetes_secret.tls.0.metadata.0.name}/tls.crt"
            tls_key_file = "/vault/userconfig/${kubernetes_secret.tls.0.metadata.0.name}/tls.key"
            tls_ca_cert_file = "/vault/userconfig/${kubernetes_secret.tls_ca.0.metadata.0.name}/ca.pem"

            tls_require_and_verify_client_cert = false
            tls_disable_client_certs           = true
          }

          storage "file" {
            path = "/vault/data"
          }
          EOF
        }
        
        extraVolumes = [
          {
            type = "secret"
            name = kubernetes_secret.tls.0.metadata.0.name
          },
          {
            type = "secret"
            name = kubernetes_secret.tls_ca.0.metadata.0.name
          }
        ]
        extraEnvironmentVars = {
          VAULT_CAPATH = "/vault/userconfig/${kubernetes_secret.tls_ca.0.metadata.0.name}/ca.pem"
          VAULT_SKIP_VERIFY = false
        }
      }
      ui = {
        enabled         = true
        externalPort    = 8200
        serviceNodePort = null
        serviceType     = "ClusterIP"
      }
    })]
}

# Let's set up the ingress for the vault interface
resource "kubernetes_ingress_v1" "ingress_vault_ui" {
  count = length(helm_release.vault)

  metadata {
    name = "ingress-vault-ui"
    namespace = kubernetes_namespace.vault.0.metadata.0.name

    annotations = {
      "cert-manager.io/cluster-issuer"                = "default-issuer"
      "nginx.ingress.kubernetes.io/backend-protocol"  = "HTTPS"
    }
  spec {
    ingress_class_name = "public"

    tls {
      hosts       = [locals.vault_addr]
      secret_name = "vault-tls"
    }

    rule {
      host = locals.vault_addr

      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "vault-ui"
              port {
                number = 8200
              }
            }
          }
        }
      }
    }
  }
  }
}
