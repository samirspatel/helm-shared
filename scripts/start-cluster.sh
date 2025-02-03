#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHART_DIR="$SCRIPT_DIR/../charts/web-application"

# Ensure we're working with absolute paths
if [ ! -d "$CHART_DIR" ]; then
    echo "❌ Error: Chart directory not found at $CHART_DIR"
    exit 1
fi

# Check if cluster exists
if ! k3d cluster list | grep -q "demo"; then
    echo "🚀 Creating new k3d cluster..."
    k3d cluster create demo \
        --api-port 6550 \
        --agents 1 \
        --port "80:80@loadbalancer" \
        --port "443:443@loadbalancer" \
        --wait

    echo "⏳ Waiting for cluster to be ready..."
    kubectl wait --for=condition=ready node --all --timeout=60s

    # Pre-pull the nginx image to all nodes
    echo "📥 Pre-pulling required images..."
    k3d image import nginx:latest -c demo
else
    echo "✅ Using existing k3d cluster 'demo'"
fi

# Add local domain to /etc/hosts if not already present
if ! grep -q "web-application.local" /etc/hosts; then
    echo "📝 Adding web-application.local to /etc/hosts..."
    echo "127.0.0.1 web-application.local" | sudo tee -a /etc/hosts
else
    echo "✅ web-application.local already in /etc/hosts"
fi

# Delete existing application if it exists
if helm list | grep -q "my-app"; then
    echo "🗑️  Removing existing application..."
    helm uninstall my-app
    # Wait for pods to be deleted
    echo "⏳ Waiting for old pods to be removed..."
    kubectl wait --for=delete pod -l app.kubernetes.io/instance=my-app --timeout=30s 2>/dev/null || true
fi

# Install the Helm chart
echo "📦 Installing Helm chart..."
helm upgrade --install my-app "$CHART_DIR" --set fullnameOverride=my-app

# Function to check pod status
check_pod_status() {
    echo "📊 Checking pod status..."
    kubectl get pods -l app.kubernetes.io/instance=my-app -o wide
    echo ""
    echo "📝 Pod events:"
    kubectl get events --field-selector involvedObject.kind=Pod --sort-by='.lastTimestamp' | grep my-app || true
    echo ""
    echo "🔍 Pod details:"
    kubectl describe pods -l app.kubernetes.io/instance=my-app
}

# Wait for the pod to be ready with better error handling
echo "⏳ Waiting for application pod to be ready..."
TIMEOUT=120  # Increased timeout to 2 minutes
INTERVAL=10  # Check every 10 seconds

for ((i=0; i<=$TIMEOUT; i+=$INTERVAL)); do
    if kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=my-app --timeout=${INTERVAL}s >/dev/null 2>&1; then
        echo "✅ Pod is ready!"
        break
    fi
    
    if [ $i -eq $TIMEOUT ]; then
        echo "❌ Pod did not become ready within $TIMEOUT seconds"
        check_pod_status
        exit 1
    fi
    
    echo "⏳ Still waiting for pod to be ready... ($i/$TIMEOUT seconds)"
    if [ $((i % 30)) -eq 0 ]; then  # Show detailed status every 30 seconds
        check_pod_status
    fi
done

echo "✨ Setup complete! Your cluster is ready."
echo "🌐 You can access your application at: http://web-application.local"
echo ""
echo "Useful commands:"
echo "  kubectl get pods,svc,ingress    # Check resources"
echo "  kubectl logs -l app.kubernetes.io/instance=my-app    # Check logs"
echo "  helm list    # List Helm releases"
echo "  kubectl port-forward svc/my-app 8080:80  # Access directly via port-forward" 