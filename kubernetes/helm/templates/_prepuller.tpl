{{- define "suite.prepullertemplate" }}
{{- if .Values.global.prepuller.enabled }}
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: {{ include "suite.fullname" . }}-puller
  namespace: {{ .Values.global.prepuller.namespace }}
  labels:
    {{- include "suite.labels" . | nindent 4 }}
    {{- if len .Values.global.commonLabels }}
    {{- toYaml .Values.global.commonLabels | nindent 4 }}
    {{- end }}
spec:
  selector:
    matchLabels:
      {{- include "suite.selectorLabels" . | nindent 6 }}
      {{- if len .Values.global.commonSelectorLabels }}
      {{- toYaml .Values.global.commonSelectorLabels | nindent 6 }}
      {{- end }}
  template:
    metadata:
      labels:
        {{- include "suite.selectorLabels" . | nindent 8 }}
        {{- if len .Values.global.commonSelectorLabels }}
        {{- toYaml .Values.global.commonSelectorLabels | nindent 8 }}
        {{- end }}
    spec:
      restartPolicy: Always
      {{- with .Values.global.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ .Chart.Name }}-puller
          image: "{{ .Values.global.image.registry | default .Values.image.registry }}/{{ .Values.image.repository }}{{ if .Values.image.tag }}:{{ .Values.image.tag }}{{ else if .Values.image.digest }}@{{ .Values.image.digest }}{{ else }}:{{ .Chart.AppVersion }}{{ end }}"
          imagePullPolicy: Always
          command: ["sleep", "infinity"]
      tolerations:
        - operator: "Exists"
{{- end }}
{{- end }}