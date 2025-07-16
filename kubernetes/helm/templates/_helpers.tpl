{{/*
Expand the name of the chart.
*/}}
{{- define "suite.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "suite.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "suite.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create volume name for deployments.
*/}}
{{- define "suite.volumeName" -}}
{{ include "suite.fullname" . }}-data
{{- end }}

{{/*
The name for fluentbit configmap.
*/}}
{{- define "suite.fluentBitConfigName" -}}
{{- printf "%s-%s" ( include "suite.fullname" .) "fluentbit-configmap" }}
{{- end }}

{{/*
Common securityContext
*/}}
{{- define "suite.securityContext" -}}
{{- if .Values.global.securityContext.enabled }}
securityContext:
  runAsNonRoot: true
  allowPrivilegeEscalation: false
  runAsUser: {{ .Values.global.securityContext.runAsUser }}
  capabilities:
    drop:
      - ALL
  seccompProfile:
    type: "RuntimeDefault"
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "suite.labels" -}}
helm.sh/chart: {{ include "suite.chart" . }}
{{ include "suite.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "removeSingleQuotes" -}}
  {{- $value := . -}}
  {{- $value | replace "'" "" -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "suite.selectorLabels" -}}
app.kubernetes.io/name: {{ include "suite.name" . }}
app: {{ include "suite.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
release: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
/!\ NOT IN USE /!\
*/}}
{{- define "suite.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "suite.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "call-nested" }}
    {{- $dot := index . 0 }}
    {{- $subchart := index . 1 }}
    {{- $template := index . 2 }}
    {{- include $template (dict "Chart" (dict "Name" $subchart) "Values" (index $dot.Values $subchart) "Release" $dot.Release "Capabilities" $dot.Capabilities) }}
{{- end }}

{{- define "registry.imagePullSecret" -}}
{{- with .Values.registryCredentials -}}
  {{- $authValue := .auth | default (printf "%s:%s" .username .password | b64enc) -}}
  {{- $authPart := printf "\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}" .registry .username .password .email $authValue -}}
  {{- $proxiesPart := "" -}}
  {{- if and .proxy .proxy.enabled -}}
    {{- $proxiesPart = printf ",\"proxies\":{\"default\":{\"httpProxy\":\"%s\",\"httpsProxy\":\"%s\"}}" .proxy.host .proxy.host -}}
  {{- end -}}
  {{- $dockerConfigJson := printf "{%s%s}" $authPart $proxiesPart -}}
  {{- printf "%s" $dockerConfigJson | b64enc -}}
{{- end -}}
{{- end -}}

{{/*
Generate nodeSelector block by merging local and global selectors
*/}}
{{- define "custom.nodeSelector" -}}
  {{- $nodeSelector := merge (default dict .Values.global.nodeSelector) (default dict .Values.nodeSelector) }}
  {{- with $nodeSelector }}
nodeSelector:
    {{- toYaml . | nindent 8 }}
  {{- end }}
{{- end }}

{{/*
Generate affinity block by merging local and global affinities
*/}}
{{- define "custom.affinity" -}}
  {{- $affinity := merge (default dict .Values.affinity) (default dict .Values.global.affinity) }}
  {{- with $affinity }}
affinity:
    {{- toYaml . | nindent 8 }}
  {{- end }}
{{- end }}

{{/*
Generate tolerations block by merging local and global tolerations
*/}}
{{- define "custom.tolerations" -}}
  {{- $tolerations := concat (default list .Values.global.tolerations) (default list .Values.tolerations) }}
  {{- with $tolerations }}
tolerations:
    {{- toYaml . | nindent 8 }}
  {{- end }}
{{- end }}