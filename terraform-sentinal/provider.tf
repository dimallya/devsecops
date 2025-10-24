terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.7.0"
    }
  }
}

provider "vault" {
  address = "https://169.63.183.243:8200"
  namespace = "ecosystem"
  skip_child_token = true
  skip_tls_verify = true
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.role_id
      secret_id = var.secret_id
    }
  }
}

# provider "vault" {
#   # It is strongly recommended to configure this provider through the
#   # environment variables:
#   #    - VAULT_ADDR
#   #    - VAULT_TOKEN
#   #    - etc.  
# }

provider "kubernetes" {
  host     = var.kube_host
  insecure = true
  token    = data.vault_kubernetes_service_account_token.kube_token.service_account_token
}
