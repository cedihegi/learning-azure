if [ -z "${ENVIRONMENT}" ]; then
    echo "\$ENVIRONMENT was not set! Aborting"
else
    terraform plan -var-file environment/$ENVIRONMENT/variables.tfvars -out=plan_$ENVIRONMENT.tfplan
fi
