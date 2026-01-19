# bentopdf

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.15.4](https://img.shields.io/badge/AppVersion-1.15.4-informational?style=flat-square)

A Helm chart for BentoPDF - PDF manipulation service using BentoML

**Homepage:** <https://github.com/alam00000/bentopdf>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| deimosfr | <deimosfr@gmail.com> |  |

## Source Code

* <https://github.com/alam00000/bentopdf>
* <https://github.com/deimosfr/deimosfr-charts/tree/main/charts/bentopdf>

## Requirements

Kubernetes: `>=1.19.0-0`

## Configuration

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| config.logLevel | string | `"INFO"` | Log level: DEBUG, INFO, WARNING, ERROR |
| config.workers | int | `1` | Number of workers |
| fullnameOverride | string | `""` | String to fully override bentopdf.fullname template |
| httpRoute | object | `{"annotations":{},"enabled":false,"hostnames":["chart-example.local"],"parentRefs":[{"name":"gateway","sectionName":"http"}]}` | Expose the service via gateway-api HTTPRoute Requires Gateway API resources and suitable controller installed within the cluster (see: https://gateway-api.sigs.k8s.io/guides/) |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"bentopdf/bentopdf-simple"` | Docker image repository for BentoPDF (uses nginx-unprivileged for enhanced security) |
| image.tag | string | "" | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | Image pull secrets for private Docker registry |
| ingress.annotations | object | `{}` | Additional ingress annotations @example annotations:   cert-manager.io/cluster-issuer: letsencrypt-prod |
| ingress.className | string | `""` | Ingress class name |
| ingress.enabled | bool | `false` | Enable ingress resource |
| ingress.tls.enabled | bool | `false` | Enable TLS for ingress |
| ingress.tls.secretName | string | "<release-name>-bentopdf-ingress-lets-encrypt" | Secret name for TLS certificate |
| ingress.url | string | `""` | The URL for the ingress endpoint to point to the BentoPDF instance |
| livenessProbe.enabled | bool | `true` | Enable liveness probe |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/healthz"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| nameOverride | string | `""` | String to partially override bentopdf.fullname template |
| persistence.accessMode | string | `"ReadWriteOnce"` | Access mode for the persistent volume |
| persistence.enabled | bool | `false` | Enable persistent storage |
| persistence.existingClaim | string | "" | Use an existing PVC |
| persistence.mountPath | string | `"/tmp/bentopdf"` | Mount path for persistent storage |
| persistence.size | string | `"10Gi"` | Size of the persistent volume |
| persistence.storageClass | string | "" | Storage class for the PVC |
| podAnnotations | object | `{}` | Annotations to add to pods |
| podSecurityContext.fsGroup | int | `101` | Group ID for filesystem access |
| podSecurityContext.runAsGroup | int | `101` | Group ID to run the pod |
| podSecurityContext.runAsNonRoot | bool | `true` | Run container as non-root user |
| podSecurityContext.runAsUser | int | `101` | User ID to run the pod |
| readinessProbe.enabled | bool | `true` | Enable readiness probe |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.httpGet.path | string | `"/readyz"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| readinessProbe.initialDelaySeconds | int | `10` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| readinessProbe.timeoutSeconds | int | `3` |  |
| replicaCount | int | `1` | Number of pod replicas |
| resources | object | `{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Resource limits and requests for BentoPDF |
| securityContext.allowPrivilegeEscalation | bool | `false` | Prevent privilege escalation |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `false` | Allow write access to root filesystem |
| service.annotations | object | `{}` | Additional annotations for the service |
| service.port | int | `8080` | Kubernetes Service port |
| service.targetPort | int | `8080` | Container target port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automountServiceAccountToken | bool | `false` | If the service account token should be auto mounted |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | "" | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| vpa | object | `{"enabled":false,"resourcePolicy":{},"updatePolicy":{"updateMode":"Auto"}}` | Vertical Pod Autoscaler configuration |
| vpa.enabled | bool | `false` | Enable Vertical Pod Autoscaler |
| vpa.resourcePolicy | object | `{}` | Resource policy for VPA |
| vpa.updatePolicy | object | `{"updateMode":"Auto"}` | Update policy for VPA |
