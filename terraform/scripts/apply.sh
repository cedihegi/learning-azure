if [ -z "${ENVIRONMENT}" ]; then
    echo "\$ENVIRONMENT was not set! Aborting"
else
    terraform apply -input=false plan_${ENVIRONMENT}.tfplan
fi
