{{- define "suite.servicetemplate" }}
{{- if .Values.service.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "suite.fullname" . }}
  annotations:
    {{ toYaml .Values.service.annotations | nindent 4 }}
  labels:
    {{- include "suite.labels" . | nindent 4 }}
    {{- if len .Values.global.commonLabels }}
    {{- toYaml .Values.global.commonLabels | nindent 4 }}
    {{- end }}
spec:
  type: {{ .Values.service.type }}
  {{- if .Values.service.loadBalancerIP }}
  loadBalancerIP: {{ .Values.service.loadBalancerIP }}
  {{ end }}
  ports:
    {{- range $port := .Values.service.ports }}
    - port: {{ $port.port }}
      targetPort: {{ $port.targetPort }}
      protocol: TCP
      nodePort: null
      name: {{ $port.name }}
    {{- end }}
  selector:
    {{- include "suite.selectorLabels" . | nindent 4 }}
    {{- if len .Values.global.commonSelectorLabels }}
    {{- toYaml .Values.global.commonSelectorLabels | nindent 4 }}
    {{- end }}
{{- end }}
{{- if .Values.service.headless.enabled }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "suite.fullname" . }}-headless
  annotations:
    {{ toYaml .Values.service.headless.annotations | nindent 4 }}
  labels:
    {{- include "suite.labels" . | nindent 4 }}
    {{- if len .Values.global.commonLabels }}
    {{- toYaml .Values.global.commonLabels | nindent 4 }}
    {{- end }}
spec:
  type: ClusterIP
  clusterIP: None
  publishNotReadyAddresses: true
  ports:
    {{- range $port := .Values.service.headless.ports }}
    - port: {{ $port.port }}
      targetPort: {{ $port.targetPort }}
      protocol: TCP
      name: {{ $port.name }}
    {{- end }}
  selector:
    {{- include "suite.selectorLabels" . | nindent 4 }}
    {{- if len .Values.global.commonSelectorLabels }}
    {{- toYaml .Values.global.commonSelectorLabels | nindent 4 }}
    {{- end }}
{{- end }}
{{- end }}