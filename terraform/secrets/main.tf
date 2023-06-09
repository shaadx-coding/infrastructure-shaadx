terraform {

  # Let's load the necessary providers

  required_providers {

    # External allows us to interface terraform with
    # external services
    external = {
      source = "hashicorp/external"
        version = "2.2.3"
    }

    # We are using kubernetes so we need it's provider
    # to work with it
    kubernetes = {
      source = "hashicorp/kubernetes"
        version = "2.12.1"
    }

    # Random will allow us to generate random password
    # or keys for our secrets
    random = {
      source = "hashicorp/random"
        version = "3.3.2"
    }
  }
}

# With this we load the kube config
# on our local device to communicate
# with our nodes
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "random" {}
provider "vault" {}

# This allows to mount the vault to
# our cluster
resource "vault-mount" "in-cluster" {
  path = "in-cluster"
    type = "kv" # Key-Value store
    options = {
      version = 2 # Allows to retain a configurable number of versions
    }
}
