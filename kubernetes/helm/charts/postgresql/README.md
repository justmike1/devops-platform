# postgresql

![Version: 12.3.1](https://img.shields.io/badge/Version-12.3.1-informational?style=flat-square) ![AppVersion: 12.3.1](https://img.shields.io/badge/AppVersion-12.3.1-informational?style=flat-square)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalVolumeMounts[0].mountPath | string | `"/docker-entrypoint-initdb.d/"` |  |
| additionalVolumeMounts[0].name | string | `"custom-init-scripts"` |  |
| additionalVolumes[0].configMap.defaultMode | int | `420` |  |
| additionalVolumes[0].configMap.name | string | `"postgresql-configmap"` |  |
| additionalVolumes[0].name | string | `"custom-init-scripts"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchLabels."app.kubernetes.io/name" | string | `"postgresql"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `1` |  |
| autoscaling.enabled | bool | `false` |  |
| command | list | `[]` |  |
| configMap.data."create-databases.sql" | string | `"CREATE DATABASE \"{{ .Values.global.database.name }}\" OWNER \"{{ .Values.global.database.user }}\";\nGRANT ALL PRIVILEGES ON DATABASE \"{{ .Values.global.database.name }}\" TO \"{{ .Values.global.database.user }}\";\n\n\\c {{ .Values.global.database.name }}\n\nCREATE SCHEMA IF NOT EXISTS \"{{ .Values.global.database.schema.app.name }}\" AUTHORIZATION \"{{ tpl (.Values.global.database.schema.app.user) . }}\";\nCREATE SCHEMA IF NOT EXISTS \"{{ .Values.global.database.schema.extensions.name }}\" AUTHORIZATION \"{{ tpl (.Values.global.database.schema.extensions.user) . }}\";\n"` |  |
| configMap.enabled | bool | `true` |  |
| extraEnv.BITNAMI_DEBUG | string | `"false"` |  |
| extraEnv.PGDATA | string | `"/bitnami/postgresql/data"` |  |
| extraEnv.POSTGRESQL_CLIENT_MIN_MESSAGES | string | `"error"` |  |
| extraEnv.POSTGRESQL_ENABLE_LDAP | string | `"no"` |  |
| extraEnv.POSTGRESQL_ENABLE_TLS | string | `"no"` |  |
| extraEnv.POSTGRESQL_LOG_CONNECTIONS | string | `"false"` |  |
| extraEnv.POSTGRESQL_LOG_DISCONNECTIONS | string | `"false"` |  |
| extraEnv.POSTGRESQL_LOG_HOSTNAME | string | `"false"` |  |
| extraEnv.POSTGRESQL_PGAUDIT_LOG_CATALOG | string | `"off"` |  |
| extraEnv.POSTGRESQL_PORT_NUMBER | string | `"5432"` |  |
| extraEnv.POSTGRESQL_SHARED_PRELOAD_LIBRARIES | string | `"pgaudit"` |  |
| extraEnv.POSTGRESQL_VOLUME_DIR | string | `"/bitnami/postgresql"` |  |
| extraEnv.POSTGRES_PASSWORD | string | `"{{ .Values.global.database.password }}"` |  |
| extraEnv.POSTGRES_POSTGRES_PASSWORD | string | `"{{ .Values.global.database.password }}"` |  |
| extraEnv.POSTGRES_USER | string | `"{{ .Values.global.database.user }}"` |  |
| extraSidecars | list | `[]` |  |
| fluentBitSidecar.enabled | bool | `false` |  |
| fullnameOverride | string | `"postgresql"` |  |
| healthProbes.livenessProbe.exec.command[0] | string | `"/bin/sh"` |  |
| healthProbes.livenessProbe.exec.command[1] | string | `"-c"` |  |
| healthProbes.livenessProbe.exec.command[2] | string | `"exec pg_isready -U \"admin\" -h 127.0.0.1 -p 5432"` |  |
| healthProbes.livenessProbe.failureThreshold | int | `6` |  |
| healthProbes.livenessProbe.initialDelaySeconds | int | `30` |  |
| healthProbes.livenessProbe.periodSeconds | int | `10` |  |
| healthProbes.livenessProbe.successThreshold | int | `1` |  |
| healthProbes.livenessProbe.timeoutSeconds | int | `5` |  |
| healthProbes.name | string | `"postgresql"` |  |
| healthProbes.ports[0].containerPort | int | `5432` |  |
| healthProbes.ports[0].name | string | `"tcp-postgresql"` |  |
| healthProbes.ports[0].protocol | string | `"TCP"` |  |
| healthProbes.readinessProbe.exec.command[0] | string | `"/bin/sh"` |  |
| healthProbes.readinessProbe.exec.command[1] | string | `"-c"` |  |
| healthProbes.readinessProbe.exec.command[2] | string | `"-e"` |  |
| healthProbes.readinessProbe.exec.command[3] | string | `"exec pg_isready -U \"admin\" -h 127.0.0.1 -p 5432\n[ -f /opt/bitnami/postgresql/tmp/.initialized ] || [ -f /bitnami/postgresql/.initialized ]\n"` |  |
| healthProbes.readinessProbe.failureThreshold | int | `6` |  |
| healthProbes.readinessProbe.initialDelaySeconds | int | `5` |  |
| healthProbes.readinessProbe.periodSeconds | int | `10` |  |
| healthProbes.readinessProbe.successThreshold | int | `1` |  |
| healthProbes.readinessProbe.timeoutSeconds | int | `5` |  |
| image.digest | string | `""` |  |
| image.pullPolicy | string | `""` |  |
| image.registry | string | `"docker.io/bitnami"` |  |
| image.repository | string | `"postgresql"` |  |
| image.tag | string | `"17.4.0-debian-12-r11"` |  |
| kind | string | `"StatefulSet"` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| persistentVolume.enabled | bool | `true` |  |
| persistentVolume.mountPath | string | `"/bitnami/postgresql"` |  |
| persistentVolume.size | string | `"10Gi"` |  |
| podAnnotations | object | `{}` |  |
| podManagementPolicy | string | `"Parallel"` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"1"` |  |
| resources.limits.memory | string | `"4Gi"` |  |
| resources.requests.cpu | string | `"500m"` |  |
| resources.requests.memory | string | `"2Gi"` |  |
| service.annotations | object | `{}` |  |
| service.enabled | bool | `true` |  |
| service.headless.annotations | object | `{}` |  |
| service.headless.enabled | bool | `true` |  |
| service.headless.ports[0].name | string | `"tcp-postgresql"` |  |
| service.headless.ports[0].port | int | `5432` |  |
| service.headless.ports[0].targetPort | string | `"tcp-postgresql"` |  |
| service.ports[0].name | string | `"tcp-postgresql"` |  |
| service.ports[0].port | int | `5432` |  |
| service.ports[0].targetPort | string | `"tcp-postgresql"` |  |
| service.type | string | `"ClusterIP"` |  |
| springApplicationJson.enabled | bool | `false` |  |
| strategy | object | `{}` |  |
| tolerations | object | `{}` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
