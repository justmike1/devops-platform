{{- define "suite.configmaptemplate" }}
{{- if .Values.configMap.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "suite.fullname" . }}-configmap
  labels:
    {{- include "suite.labels" . | nindent 4 }}
    {{- if len .Values.global.commonLabels }}
    {{- toYaml .Values.global.commonLabels | nindent 4 }}
    {{- end }}
data:
  {{- range $key, $value := .Values.configMap.data }}
  {{ $key }}: {{ quote (tpl $value $) }}
  {{- end }}
{{- end }}
{{- end }}
