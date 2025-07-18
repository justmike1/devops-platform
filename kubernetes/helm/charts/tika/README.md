# tika

![Version: 3.1.0](https://img.shields.io/badge/Version-3.1.0-informational?style=flat-square) ![AppVersion: 3.1.0](https://img.shields.io/badge/AppVersion-3.1.0-informational?style=flat-square)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalVolumeMounts | list | `[]` |  |
| additionalVolumes | list | `[]` |  |
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| autoscaling.targetMemoryUtilizationPercentage | string | `nil` |  |
| command | list | `[]` |  |
| configMap.enabled | bool | `false` |  |
| extraEnv.TZ | string | `"{{ .Values.global.timezone }}"` |  |
| extraSidecars | list | `[]` |  |
| fluentBitSidecar.enabled | bool | `false` |  |
| fluentBitSidecar.logPath | string | `""` |  |
| fullnameOverride | string | `"tika"` |  |
| healthProbes.livenessProbe.failureThreshold | int | `20` |  |
| healthProbes.livenessProbe.httpGet.path | string | `"/"` |  |
| healthProbes.livenessProbe.httpGet.port | int | `9998` |  |
| healthProbes.livenessProbe.httpGet.scheme | string | `"HTTP"` |  |
| healthProbes.livenessProbe.initialDelaySeconds | int | `15` |  |
| healthProbes.livenessProbe.periodSeconds | int | `5` |  |
| healthProbes.livenessProbe.successThreshold | int | `1` |  |
| healthProbes.livenessProbe.timeoutSeconds | int | `30` |  |
| healthProbes.readinessProbe.failureThreshold | int | `20` |  |
| healthProbes.readinessProbe.httpGet.path | string | `"/"` |  |
| healthProbes.readinessProbe.httpGet.port | int | `9998` |  |
| healthProbes.readinessProbe.httpGet.scheme | string | `"HTTP"` |  |
| healthProbes.readinessProbe.initialDelaySeconds | int | `15` |  |
| healthProbes.readinessProbe.periodSeconds | int | `5` |  |
| healthProbes.readinessProbe.successThreshold | int | `1` |  |
| healthProbes.readinessProbe.timeoutSeconds | int | `30` |  |
| image.digest | string | `""` |  |
| image.registry | string | `"docker.io"` |  |
| image.repository | string | `"tika"` |  |
| image.tag | string | `""` |  |
| kind | string | `"Deployment"` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| persistentVolume.enabled | bool | `false` |  |
| podAnnotations | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.ephemeral-storage | string | `"256Mi"` |  |
| resources.limits.memory | string | `"4Gi"` |  |
| resources.requests.cpu | string | `"250m"` |  |
| resources.requests.ephemeral-storage | string | `"256Mi"` |  |
| resources.requests.memory | string | `"2Gi"` |  |
| service.annotations | object | `{}` |  |
| service.enabled | bool | `true` |  |
| service.headless.enabled | bool | `false` |  |
| service.ports[0].name | string | `"http"` |  |
| service.ports[0].port | int | `9998` |  |
| service.ports[0].targetPort | string | `"http"` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.create | bool | `false` |  |
| springApplicationJson.enabled | bool | `false` |  |
| strategy | object | `{}` |  |
| tolerations | object | `{}` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
