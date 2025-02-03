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
helm install my-release helm-shared/web-application
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

The release workflow:
1. Checks out the repository
2. Configures Git with the GitHub Actions bot
3. Installs Helm
4. Uses the chart-releaser action to:
   - Package the Helm chart
   - Create a new GitHub release
   - Update the Helm repository index

New versions are automatically released based on the version specified in `Chart.yaml`. To release a new version:

1. Update the `version` field in `charts/web-application/Chart.yaml`
2. Commit and push your changes to the main branch
3. The GitHub Action will automatically create a new release

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue in the GitHub repository.
