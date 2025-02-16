# Web Application Helm Chart

A reusable Helm chart for deploying web applications on Kubernetes. This chart provides a standardized way to deploy web applications with common configurations for deployments, services, ingress, and more.

## Features

- Configurable deployment settings
- Service configuration
- Optional ingress support
- ConfigMap and Secret management
- Environment variable configuration
- Resource management

## Prerequisites

- Kubernetes 1.16+
- Helm 3.x

## Installation

Add the Helm repository:

```bash
# helm repo add helm-shared https://samirspatel.github.io/helm-shared
helm repo add helm-shared https://raw.githubusercontent.com/samirspatel/helm-shared/refs/heads/gh-pages
helm repo update
```

Install the chart:

```bash
helm upgrade --install my-web-app helm-shared/web-application --set fullnameOverride=my-web-app
```

## Example Usage

Create a `values.yaml` file for you specific application in your app repo e.g. `my-web-app`

```yaml
deployment:
  name: my-web-app
  replicas: 2
  image:
    repository: docker.io/myorg/my-web-app
    tag: 1.2.3

service:
  type: ClusterIP
  port: 8080

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: my-web-app.local
      paths:
        - path: /
          pathType: Prefix

configMap:
  enabled: true
  data:
    APP_CONFIG: |
      key1=value1
      key2=value2
```

Install the chart with custom values:

```bash
helm install my-web-app helm-shared/web-application -f values.yaml
```

## Release Process

This chart uses GitHub Actions for automated releases. The release process is triggered when changes are pushed to the `main` or `chart` branches.

### New helm chart release

To release a new version:

1. Update the `version` field in the chart yaml file for your particular chart e.g. `charts/web-application/Chart.yaml`
2. Commit and push your changes to the `main` branch
3. The GitHub Action will automatically:
   - Create a new release tagged with the chart version e.g. `web-application` chart version `0.3.0` will create a release with tag `web-application-0.3.0`

## Local Development

To automatically set up a local development environment with k3d:

1. Make sure you have the following prerequisites installed:
   - [k3d](https://k3d.io/)
   - [kubectl](https://kubernetes.io/docs/tasks/tools/)
   - [Helm](https://helm.sh/docs/intro/install/)

2. Run the start script:
   ```bash
   ./scripts/local.sh
   ```

   This script will:
   - Create a k3d cluster with proper port mappings
   - Configure local domain in /etc/hosts
   - Install the sample `web-application` Helm chart
   - Wait for everything to be ready

3. Access your sample application at:
   ```
   http://web-application.local
   ```

To clean up:
```bash
k3d cluster delete local
```
