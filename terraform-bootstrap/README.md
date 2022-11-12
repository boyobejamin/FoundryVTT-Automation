# terraform-bootstrap

```
export ENV="demo"
terraform init -backend-config=../env/$ENV/backend.tfvars
terraform apply -auto-approve -var-file=../env/$ENV/bootstrap.tfvars
```
