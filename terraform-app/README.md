# terraform-app

```
export ENV="demo"
terraform init -backend-config=../env/$ENV/backend.tfvars
terraform apply -auto-approve -var-file=../env/$ENV/app.tfvars
```

# destroy

```console
export ENV="demo"
terraform init -backend-config=../env/$ENV/backend.tfvars
terraform destroy \
    -auto-approve \
    -var-file=../env/$ENV/app.tfvars \
    -target=aws_lb_target_group.foundry \
    -target=aws_alb_listener_rule.foundry_1 \
    -target=aws_alb_listener_rule.foundry_2 \
    -target=aws_ecs_service.vtt
```