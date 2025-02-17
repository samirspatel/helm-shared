#!/bin/bash

# Check and install required tools
check_and_install_brew() {
    if ! command -v brew &> /dev/null; then
        echo "🍺 Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

check_and_install_tool() {
    local tool=$1
    local cask=$2
    if ! command -v "$tool" &> /dev/null; then
        echo "📦 $tool not found. Installing $tool..."
        if [ "$cask" = "true" ]; then
            brew install --cask "$tool"
        else
            brew install "$tool"
        fi
    else
        echo "✅ $tool is already installed"
    fi
}

# Install required tools
check_and_install_brew
check_and_install_tool "docker" "true"
check_and_install_tool "k3d"
check_and_install_tool "helm"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHART_DIR="$SCRIPT_DIR/../charts/web-application"

# Ensure we're working with absolute paths
if [ ! -d "$CHART_DIR" ]; then
    echo "❌ Error: Chart directory not found at $CHART_DIR"
    exit 1
fi

# Check if cluster exists
if ! k3d cluster list | grep -q "local"; then
    echo "Creating k3d cluster..."
    k3d cluster create local \
        --api-port 6550 \
        --port "80:80@loadbalancer" \
        --port "443:443@loadbalancer" \
        --k3s-arg '--disable=traefik@server:0' \
        --wait

    echo "⏳ Waiting for cluster to be ready..."
    kubectl wait --for=condition=ready node --all --timeout=60s

    # Pre-pull the nginx image to all nodes
    echo "📥 Pre-pulling required images..."
    k3d image import nginx:latest -c local
else
    echo "✅ Using existing k3d cluster 'local'"
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

i=0
while [ $i -le $TIMEOUT ]; do
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
    
    i=$((i + INTERVAL))
done

echo "✨ Setup complete! Your cluster is ready."
echo "🌐 You can access the sample web application at: http://web-application.local"
echo ""
echo "Useful commands:"
echo "  kubectl get pods,svc,ingress    # Check resources"
echo "  kubectl logs -l app.kubernetes.io/instance=my-app    # Check logs"
echo "  helm list    # List Helm releases"
echo "  kubectl port-forward svc/my-app 8080:80  # Access directly via port-forward" 

open http://web-application.local