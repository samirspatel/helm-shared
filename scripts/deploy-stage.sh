#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHART_DIR="$SCRIPT_DIR/../charts/web-application"
VALUES_FILE="$CHART_DIR/values.stage.yaml"

# Check required environment variables
required_vars=(
    "AWS_DOMAIN"
    "AWS_SECURITY_GROUP_ID"
    "AWS_CERTIFICATE_ARN"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Error: $var environment variable is required"
        echo ""
        echo "Please set the following environment variables:"
        echo "  export AWS_DOMAIN=example.com"
        echo "  export AWS_SECURITY_GROUP_ID=sg-xxxxxx"
        echo "  export AWS_CERTIFICATE_ARN=arn:aws:acm:region:account:certificate/xxxxx"
        exit 1
    fi
done

# Ensure we're working with absolute paths
if [ ! -f "$VALUES_FILE" ]; then
    echo "❌ Error: values.stage.yaml not found at $VALUES_FILE"
    exit 1
fi

# Create a temporary values file with substituted variables
TEMP_VALUES=$(mktemp)
trap "rm -f $TEMP_VALUES" EXIT

echo "📝 Preparing values file with staging configuration..."
cat "$VALUES_FILE" | \
    sed "s|\${AWS_DOMAIN}|$AWS_DOMAIN|g" | \
    sed "s|\${AWS_SECURITY_GROUP_ID}|$AWS_SECURITY_GROUP_ID|g" | \
    sed "s|\${AWS_CERTIFICATE_ARN}|$AWS_CERTIFICATE_ARN|g" > "$TEMP_VALUES"

# Deploy the application
echo "🚀 Deploying application to staging..."
helm upgrade --install my-app-stage "$CHART_DIR" \
    -f "$TEMP_VALUES" \
    --set fullnameOverride=my-app-stage

# Wait for the deployment to be ready
echo "⏳ Waiting for deployment to be ready..."
kubectl rollout status deployment/my-app-stage

echo "✨ Deployment complete!"
echo ""
echo "To verify the deployment:"
echo "  kubectl get pods,svc,ingress -l environment=staging"
echo "  kubectl describe ingress my-app-stage"
echo ""
echo "Your staging application will be available at:"
echo "  https://stage.web-application.$AWS_DOMAIN"
echo ""
echo "Useful commands:"
echo "  kubectl logs -l environment=staging    # View logs"
echo "  kubectl exec -it \$(kubectl get pod -l environment=staging -o name | head -1) -- sh    # Shell access" 