if [ -z "${ENVIRONMENT}" ]; then
    echo "\$ENVIRONMENT was not set! Aborting"
else
    terraform init -backend-config environment/$ENVIRONMENT/backend.hcl -input=false -upgrade -reconfigure
fi
