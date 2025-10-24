### Setup of integration with EXternal Vault

#### Step 1 - Create sevice and enpoint for vault
```sh
oc new-project external-vault
# oc apply -f external-vault.yaml
```

#### Step 2 - Craete vault server running in external mode
```sh
# helm repo add hashicorp https://helm.releases.hashicorp.com
# helm repo update
helm install external-vault hashicorp/vault --set "global.externalVaultAddr=https://169.63.183.243:8200" --set "global.openshift=true" --set "injector.enabled=false"
```

#### Step 3 - Create Vault SA secret
In Kubernetes 1.24+, the token is not created automatically, and you must create it explicitly.
```sh
oc apply -f vault-cluster-role-binding.yaml
```

#### Step 4 - Verify the SA Issuer(iss) for TokenReview from Vault.
```sh
echo '{"apiVersion": "authentication.k8s.io/v1", "kind": "TokenRequest"}' \
  | kubectl create -f- --raw /api/v1/namespaces/external-vault/serviceaccounts/external-vault/token \
  | jq -r '.status.token' \
  | cut -d . -f2 \
  | base64 -d
```

#### Step 4 - Export Values
```sh
export VAULT_NS=external-vault
export VAULT_HELM_SECRET_NAME=$(oc get secrets -n $VAULT_NS --output=json | jq -r '.items[].metadata | select(.name|startswith("external-vault-token-")).name')
export TOKEN_REVIEW_JWT=$(oc get secret $VAULT_HELM_SECRET_NAME -n $VAULT_NS --output='go-template={{ .data.token }}' | base64 --decode)
# export KUBE_CA_CERT=$(oc get secret $VAULT_HELM_SECRET_NAME -n $VAULT_NS --output=json | jq -r '.data."ca.crt"' | base64 --decode)
export KUBE_HOST=$(oc config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')
```

#### Step 5 - Step kubeAuth for external vault
```sh
export VAULT_ADDR='https://169.63.183.243:8200'
export VAULT_NAMESPACE=ecosystem
vault login

vault auth enable -path openshift-auth-mount kubernetes
vault write auth/openshift-auth-mount/config \
    disable_local_ca_jwt=true \
    disable_iss_validation=false \
    token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
    kubernetes_host="$KUBE_HOST" \
    kubernetes_ca_cert=@root-ca-ibm.pem \
    issuer="https://kubernetes.default.svc"
```

