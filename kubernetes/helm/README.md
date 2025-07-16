# suite

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

Platform Helm Chart

## Requirements

| Repository | Name | Version |
|------------|------|---------|
|  | kafka | 3.9.0 |
|  | opensearch | 2.19.1 |
|  | postgresql | 12.3.1 |
|  | rabbitmq | 4.1.1 |
|  | redis | 8.0.2 |
|  | tika | 3.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.additionalConfigurationFiles | object | `{}` | To add additional configuration files for the JDBC driver |
| global.affinity | object | `{}` | Affinity for all components |
| global.auth.client.secret | string | `""` | oauth2 client secret |
| global.auth.jwt.secret | string | `""` | JWT secret |
| global.broker.bootstrapUrl | string | `"kafka:9092"` | Platform's kafka client host URL |
| global.broker.consumerUrl | string | `"kafka.{{ .Release.Namespace }}.svc.cluster.local:9092"` | Platform's kafka consumer host URL |
| global.broker.producerUrl | string | `"{{- if .Values.global.highAvailability.enabled }}\nkafka-0.kafka-headless.{{ .Release.Namespace }}.svc.cluster.local:9092,\nkafka-1.kafka-headless.{{ .Release.Namespace }}.svc.cluster.local:9092,\nkafka-2.kafka-headless.{{ .Release.Namespace }}.svc.cluster.local:9092\n{{- else }}\nkafka-0.kafka-headless.{{ .Release.Namespace }}.svc.cluster.local:9092\n{{- end }}"` | Platform's kafka broker list / producer host URL |
| global.broker.replicationFactor | string | `"{{- if .Values.global.highAvailability.enabled }}2{{- else }}1{{- end }}"` | Platform's kafka replication factor ( >= 2) |
| global.broker.sslCertificateAuthorityLocation | string | `""` | Platform's kafka ssl certificate authority location |
| global.broker.sslCertificateLocation | string | `""` | Platform's kafka ssl certificate location |
| global.broker.sslKeyLocation | string | `""` | Platform's kafka ssl key location |
| global.broker.sslKeyPassword | string | `""` | Platform's kafka ssl key password |
| global.broker.sslKeystoreLocation | string | `""` | Platform's kafka ssl keystore location |
| global.broker.sslKeystorePassword | string | `""` | Platform's kafka ssl keystore password |
| global.broker.sslTruststoreLocation | string | `""` | Platform's kafka ssl truststore location |
| global.broker.sslTruststorePassword | string | `""` | Platform's kafka ssl truststore password |
| global.broker.topicPrefix | string | `"PT_"` | Platform's kafka topic prefix |
| global.commonLabels | object | `{}` | Additional common labels (e.g. environment: prod) |
| global.commonSelectorLabels | object | `{}` | Additional common selector labels (e.g. environment: prod) |
| global.database.flywayPassword | string | `"{{ .Values.global.database.password }}"` | Database flyway migration password (defualt is the same as the database password) |
| global.database.flywayUser | string | `"{{ .Values.global.database.user }}"` | Database flyway migration user (defualt is the same as the database user) |
| global.database.host | string | `"postgresql"` | Database host name |
| global.database.name | string | `"platform"` | Database name |
| global.database.password | string | `"suite"` | Database common password |
| global.database.port | string | `"5432"` | Database port |
| global.database.schema.app.name | string | `"app"` | Database schema name for app platform |
| global.database.schema.app.password | string | `"{{ .Values.global.database.password }}"` | Database schema password for app platform |
| global.database.schema.app.user | string | `"{{ .Values.global.database.user }}"` | Database schema user for app platform |
| global.database.schema.extensions.name | string | `"extensions"` | Database schema name for extensions |
| global.database.schema.extensions.password | string | `"{{ .Values.global.database.password }}"` | Database schema password for extensions |
| global.database.schema.extensions.user | string | `"{{ .Values.global.database.user }}"` | Database schema user for extensions |
| global.database.user | string | `"admin"` | Database common user |
| global.fluentBitSidecar.image.digest | string | `""` | fluent-bit sidecar image digest |
| global.fluentBitSidecar.image.pullPolicy | string | `"IfNotPresent"` | fluent-bit sidecar image pull policy |
| global.fluentBitSidecar.image.registry | string | `"docker.io"` | fluent-bit sidecar image registry |
| global.fluentBitSidecar.image.repository | string | `"fluent-bit"` | fluent-bit sidecar image repository |
| global.fluentBitSidecar.image.tag | string | `"main-latest"` | fluent-bit sidecar image tag |
| global.highAvailability.enabled | bool | `true` | Enable high availability for all components |
| global.image.pullPolicy | string | `"IfNotPresent"` | Default image pull policy |
| global.image.registry | string | `nil` | Default image registry |
| global.imagePullSecrets[0] | object | `{"name":"registry-pull-secret"}` | Default ImagePullSecrets name created by Suite |
| global.ingress.annotations | object | `{}` | Additional ingress annotations (e.g. for kubernetes.io/ingress.class) |
| global.ingress.className | string | `""` | Ingress class name (e.g. nginx/alb/traefik/...) |
| global.ingress.domain | string | `""` | Ingress host domain |
| global.ingress.enabled | bool | `false` | Create an Ingress for the application |
| global.ingress.openshift.enabled | bool | `false` | Enable Openshift specific configuration |
| global.ingress.openshift.route.dashboards.annotations | object | `{}` | Openshift routes dashboards host services annotations |
| global.ingress.openshift.route.main.annotations | object | `{}` | Openshift routes main host services annotations |
| global.ingress.openshift.tls.termination | string | `"edge"` | Openshift routes TLS termination type |
| global.ingress.openshift.wildcardPolicy | string | `"None"` | Openshift routes wildcard policy |
| global.ingress.protocol | string | `"https"` | Ingress protocol (http/https) |
| global.ingress.subDomains.dashboards | string | `""` | Superset subdomain. (Optional but recommended) |
| global.ingress.subDomains.main | string | `""` | Main subdomain that serves the client, server and auth. |
| global.ingress.subDomains.search | string | `""` | Search subdomain to expose opensearch API. (Optional but recommended) |
| global.ingress.tls.multiDomain.dashboardsTlsSecretName | string | `""` | subdomain TLS secret name |
| global.ingress.tls.multiDomain.mainTlsSecretName | string | `""` | subdomain TLS secret name |
| global.ingress.tls.wildcard.tlsSecret.certificate | string | `""` | Wildcard TLS secret certificate |
| global.ingress.tls.wildcard.tlsSecret.key | string | `""` | Wildcard TLS secret key |
| global.ingress.tls.wildcard.tlsSecretName | string | `""` | Wildcard TLS secret name |
| global.keytab | string | `""` | To override /etc/krb5.keytab file content (Base64 encoded) |
| global.krb5Conf | string | `"[libdefaults]\ndefault_realm = EXAMPLE.COM"` | To override /etc/krb5.conf file content |
| global.logging.enabled | bool | `true` | Enable logging extraction via fluent-bit to elasticsearch for all components |
| global.logging.level | string | `"debug"` | Logging level (debug, info, warn, error) |
| global.nodeSelector | object | `{}` | Node selector for all components |
| global.opensearch.token | string | `"Nz9eOHI5Bb2B7MlTn6NJ8qlR"` | OpenSearch default admin/key pass authorization |
| global.prepuller.enabled | bool | `false` | Deploy pre-puller daemonset for all components to minimize cold starts |
| global.prepuller.namespace | string | `"default"` | Pre-puller deployment namespace |
| global.resources.requests.enabled | bool | `true` | Whether to apply subchart's resource request usage |
| global.saas.apiKey | string | `""` | API key for the proxy service to authenticate with the connector service |
| global.saas.enabled | bool | `false` | Deploy Proxy for SaaS deployments, disabled by default. If enabled, the proxy service will be deployed instead of the connector service. |
| global.securityContext.enabled | bool | `true` | Enable security context for all containers |
| global.securityContext.runAsUser | int | `1001080000` | User ID for the all containers /!\ the User ID is also used for the group ID /!\ |
| global.smtp.enabled | bool | `false` | Enable SMTP for workflow notifications |
| global.smtp.host | string | `""` | SMTP host |
| global.smtp.password | string | `""` | SMTP password |
| global.smtp.port | int | `587` | SMTP port |
| global.smtp.username | string | `""` | SMTP username |
| global.storageClass | string | `""` | Persistent volume storage class |
| global.superset.admin.password | string | `"948iUlpAtZJQu7Fn"` | Superset admin password |
| global.superset.admin.username | string | `"do-not-touch"` | Superset admin username |
| global.tests.enabled | bool | `false` | Enable tests for the platform |
| global.timezone | string | `"UTC"` | Platform timezone in docker format (e.g. America/New_York)  https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List |
| global.tolerations | list | `[]` | Tolerations for all components |
| global.truststore | object | `{}` | To add CA certificates / JKS files to the truststore |
| kafka.enabled | bool | `true` | Deploy Kafka |
| opensearch.enabled | bool | `true` | Deploy OpenSearch |
| postgresql.enabled | bool | `true` | Deploy PostgreSQL Recommended using a managed PostgreSQL solution /!\ Currently only supports PostgresSQL 14+ /!\ |
| rabbitmq.enabled | bool | `true` | Deploy RabbitMQ |
| redis.enabled | bool | `true` | Deploy Redis |
| registryCredentials.auth | string | `""` | Docker registry encoded auth (can be left blank, will be generated from username:password) |
| registryCredentials.createSecret | bool | `true` | Create a secret for the docker registry |
| registryCredentials.email | string | `""` | Docker registry email (can be left blank) |
| registryCredentials.password | string | `""` | Docker registry access token |
| registryCredentials.proxy | object | `{"enabled":false,"host":""}` | Docker proxy support |
| registryCredentials.proxy.enabled | bool | `false` | Enable proxy for the docker registry |
| registryCredentials.proxy.host | string | `""` | Proxy (e.g. proxy.example.com:3128) |
| registryCredentials.registry | string | `"https://index.docker.io/v1/"` | Default docker registry URL |
| registryCredentials.secretName | string | `"registry-pull-secret"` | Default image pull secrets created by Suite |
| registryCredentials.username | string | `""` | Docker registry username |
| superset.enabled | bool | `true` | Deploy Superset |
| tika.enabled | bool | `true` | Deploy Tika |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
