terraform {
  required_version = ">= 1.4.0"
  
  backend "local" {}
}

# Let's add our provider
provider "vault" {}
