#!/bin/bash
# =====================================
#     Author: sandow
#     Email: j.k.yulei@gmail.com
#     HomePage: www.gsandow.com
# =====================================
pwd
 ls -Rl
mv gsb-infra/pipeline/deployment/sharedservices/infra/* gsb/
cd gsb
cat <<EOF > provider_auth.tf
provider "azurerm" {
  version = "~> 1.23"
  use_msi = true
  environment  =  "china"
  client_id = "${client_id}"
  client_secret = "${client_secret}"
  subscription_id =  "${subscription_id}"
  tenant_id =  "${tenant_id}"
}
EOF
cat <<BACKEND > backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "StorageAccount-ResourceGroup"
    storage_account_name = "storterraformdpshs"
    container_name       = "tfstate"
    key                  = "sharedservices/terraform.tfstate-${servicename}-${environment}"
    access_key          = "wNcG1KNN3XqyNYHX/w6dvjbJ+iFpWbhGYrJ48FYwUA4qRSA4iLULP8tNSbiJnlsm/QSVaVhfoeP3jMwakFHLrw=="
    environment  =  "china"
  }
}
BACKEND
echo "terraform source"
ls -al
mv /opt/.terraform ./
#export AWS_ACCESS_KEY_ID=$access_key
#export AWS_SECRET_ACCESS_KEY=$secret_key
terraform init #-backend-config key=etcd -backend-config path=/terraform/ -backend-config  endpoints=http://10.231.96.211:2379
terraform plan  -var-file=values.tfvars
#terraform apply -var-file=values.tfvars -auto-approve
