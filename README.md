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
helm repo add helm-shared https://samirspatel.github.io/helm-shared
helm repo update
```

Install the chart:

```bash
helm upgrade --install my-app helm-shared/web-application --set fullnameOverride=my-app
```

## Configuration

The following table lists the configurable parameters of the web-application chart and their default values.

### Deployment Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `deployment.name` | Name of the deployment | `""` |
| `deployment.replicas` | Number of replicas | `1` |
| `deployment.image.repository` | Container image repository | `nginx` |
| `deployment.image.tag` | Container image tag | `latest` |
| `deployment.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `deployment.resources.requests.cpu` | CPU resource requests | `100m` |
| `deployment.resources.requests.memory` | Memory resource requests | `128Mi` |
| `deployment.resources.limits.cpu` | CPU resource limits | `200m` |
| `deployment.resources.limits.memory` | Memory resource limits | `256Mi` |
| `deployment.podAnnotations` | Additional pod annotations | `{}` |
| `deployment.labels` | Additional labels | `{}` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `service.targetPort` | Service target port | `80` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts configuration | See values.yaml |
| `ingress.tls` | Ingress TLS configuration | `[]` |

### ConfigMap and Secret Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `configMap.enabled` | Enable ConfigMap | `false` |
| `configMap.data` | ConfigMap data | `{}` |
| `secret.enabled` | Enable Secret | `false` |
| `secret.data` | Secret data | `{}` |

## Example Usage

Create a `values.yaml` file:

```yaml
deployment:
  name: my-web-app
  replicas: 2
  image:
    repository: my-registry/my-app
    tag: 1.0.0

service:
  type: ClusterIP
  port: 8080

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: my-app.example.com
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
helm install my-release helm-shared/web-application -f values.yaml
```

## Release Process

This chart uses GitHub Actions for automated releases. The release process is triggered when changes are pushed to the `main` or `chart` branches.

### Prerequisites

Before the release process can work, ensure:

1. GitHub Pages is enabled for your repository:
   - Go to repository Settings > Pages
   - Under "Build and deployment":
     - Source: "GitHub Actions"
     - Branch: `gh-pages` (it will be created automatically)
   - Save the configuration

2. Required repository permissions are configured (automatically set in workflow):
   - `contents: write` - For creating releases
   - `pages: write` - For updating GitHub Pages
   - `id-token: write` - For GitHub Pages deployment

3. Repository Settings:
   - Ensure the repository is public (required for GitHub Pages)
   - Under Settings > Actions > General:
     - Enable "Read and write permissions" under "Workflow permissions"
     - Check "Allow GitHub Actions to create and approve pull requests"

4. First-time setup:
   - The first push to main/chart branch will:
     - Create the gh-pages branch
     - Set up the GitHub Pages environment
     - Create the initial release
   - This might take a few minutes to complete

### Release Configuration

The release process is configured through two files:

1. `.github/workflows/release.yaml` - GitHub Actions workflow file that:
   - Triggers on pushes to `main` or `chart` branches
   - Sets up Helm and Git configuration
   - Uses chart-releaser action to package and publish charts

2. `cr.yaml` - Chart Releaser configuration file that defines:
   - Repository owner and URLs
   - GitHub Pages configuration
   - Release notes generation

### Release Process Steps

The automated release workflow:
1. Checks out the repository
2. Configures Git with the GitHub Actions bot
3. Installs Helm
4. Uses the chart-releaser action to:
   - Package the Helm chart
   - Create a new GitHub release
   - Update the Helm repository index
   - Deploy to GitHub Pages

### Creating a New Release

To release a new version:

1. Update the `version` field in `charts/web-application/Chart.yaml`
2. Commit and push your changes to the main branch
3. The GitHub Action will automatically:
   - Create a new release tagged with the chart version
   - Generate release notes
   - Update the Helm repository index
   - Make the new version available for installation

### Verifying a Release

After a release is complete, you can verify it by:

1. Updating the local Helm repository cache:
   ```bash
   helm repo update helm-shared
   ```

2. Searching for available versions:
   ```bash
   helm search repo helm-shared/web-application
   ```

3. Viewing the release on GitHub:
   - Go to the repository's Releases page
   - The new version should be listed with generated release notes

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue in the GitHub repository.

## Local Development

To quickly set up a local development environment with k3d:

1. Make sure you have the following prerequisites installed:
   - [k3d](https://k3d.io/)
   - [kubectl](https://kubernetes.io/docs/tasks/tools/)
   - [Helm](https://helm.sh/docs/intro/install/)

2. Run the start script:
   ```bash
   ./scripts/start-local-cluster.sh
   ```

   This script will:
   - Create a k3d cluster with proper port mappings
   - Configure local domain in /etc/hosts
   - Install the Helm chart
   - Wait for everything to be ready

3. Access your application at:
   ```
   http://web-application.local
   ```

To clean up:
```bash
k3d cluster delete demo
```
