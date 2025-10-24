#### Setup
additonal Vault setup 
- Connect to vault
```sh
export VAULT_ADDR='https://169.63.183.243:8200'
export VAULT_NAMESPACE=ecosystem
vault login
```

- Create new role for namespace
```sh
vault write openshift/roles/devsecops-sa-role \
    allowed_kubernetes_namespaces="*" \
    kubernetes_role_name="edit" \
    kubernetes_role_type="ClusterRole"
    token_default_ttl="20m" \
    token_max_ttl="1h"

vault policy write devsecops-approle-policy - <<EOF
path "openshift/creds/devsecops-sa-role" {
  capabilities = ["read","update"]
}
EOF

vault write auth/approle/role/devsecops \
  token_policies="devsecops-approle-policy" \
  token_ttl=760h \
  token_max_ttl=760h
```

- generate new approle creds
```sh
vault read auth/approle/role/devsecops/role-id
vault write -f auth/approle/role/devsecops/secret-id
```

#### Place the terraform State file
```
Copy terraform state file from secure store and place in the project with name 'terraform.tfstate'
```

#### Initialise The terraform
```sh
terraform init
```

#### Plan Terraform 
Plan terraform to see the draft of final state and effected resources
```sh
terraform plan
```

#### Apply Terraform
```sh
terraform apply
```
press yes when prompted