# learning-azure
A repository where I explore various aspects of Azure

# commands to get started:
**login**:
`az login` to login into any account

If a specific subscription / tenant must be selected, use:
```bash
# show tenant ids if needed:
az account list

az login --tentant <tenant-id>
```

Setting backend / Initializing:
(note: all the following commands are also found under `/terraform/scripts/..`)

```bash
export ENVIRONMENT="dev" | "int" | "prod"
terraform init -backend-config environment/$ENVIRONMENT/backend.hcl -input=false -upgrade
```

This makes sure, the further Terraform instructions will use the statefile reffered to in backend.hcl
Afterwards we can run:
```
terraform plan -input=false -var-file environment/$ENVIRONMENT/variables.tfvars -out=plan_$ENVIRONMENT.tfplan
```

Here, `variables.tfvars` is yet another file containing specific values for variables defined in `variables.tf`.


