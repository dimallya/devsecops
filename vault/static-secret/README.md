### Setup Static Secret Sync with Vault Secrets Operator.

#### Step 1 - Setup vault in kubernetes and create Kubernetes authentication in Vault
Follow the instructions [here](../vault/README.md) to setup vault. 

#### Step 2 - Enable the Key Value v2 Secrets Engine.
```sh
vault secrets enable -path=devsecops kv-v2

vault kv put devsecops/digibank/config username="test1"

vault policy write digibank - <<EOF
path "devsecops/data/digibank/config" {
   capabilities = ["read", "list"]
}
EOF
```

#### Step 3 - Create a role in Vault to enable access to secrets within the Key Value v2 secrets engine.
```sh
vault write auth/openshift-auth-mount/role/digibank \
   bound_service_account_names=default \
   bound_service_account_namespaces=argocd \
   policies=digibank \
   audience=vault \
   ttl=24h
```

#### Step 4 - Setup Vault Secrets Operator
Using Helm to deploy the Vault Secrets Operator.
```sh
helm install vault-secrets-operator hashicorp/vault-secrets-operator -n vault-secrets-operator-system --create-namespace --values vault-operator-values.yaml
```

#### Step 5 - Set up Vault authentication for the secret.
```sh
kubectl apply -f vault-auth-static.yaml
```

#### Step 3 - Create the secret names `secretkv` in the app namespace.
```sh
kubectl apply -f static-secret.yaml
```

#### Step 4 - Test the Secret sync with updating the secret in vault
```sh
vault kv put devsecops/digibank/config username="bob" password="password1234"