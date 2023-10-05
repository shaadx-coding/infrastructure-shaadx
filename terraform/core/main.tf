terraform {
  required_version = ">= 1.4.0"
  
  backend "local" {}
}

# Let's set up the kubernetes terraform agent
provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "shaadx.com"
}

# Let's connect with my helm provider
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "shaadx.com"
  }
}

