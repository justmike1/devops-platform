{{- define "suite.deploymenttemplate" }}
apiVersion: apps/v1
kind: {{ .Values.kind }}
metadata:
  name: {{ include "suite.fullname" . }}
  labels:
    {{- include "suite.labels" . | nindent 4 }}
    {{- if len .Values.global.commonLabels }}
    {{- toYaml .Values.global.commonLabels | nindent 4 }}
    {{- end }}
spec:
  {{- if eq .Values.kind "Deployment" }}
  progressDeadlineSeconds: 600
  {{- end }}  
  {{- if eq .Values.kind "StatefulSet" }}
  podManagementPolicy: {{ .Values.podManagementPolicy }}
  {{- end }}
  {{- if not .Values.autoscaling.enabled }}
  replicas: 
    {{- if .Values.global.highAvailability.enabled }}
      {{ .Values.replicaCount }}
    {{- else }}
      1
    {{- end }}
  {{- end }}
  revisionHistoryLimit: 10
  {{- if len .Values.strategy }}
  strategy:
    {{- toYaml .Values.strategy | nindent 4 }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "suite.selectorLabels" . | nindent 6 }}
      {{- if len .Values.global.commonSelectorLabels }}
      {{- toYaml .Values.global.commonSelectorLabels | nindent 6 }}
      {{- end }}
  {{- if eq .Values.kind "StatefulSet" }}
  {{- if .Values.service.headless.enabled }}
  serviceName: {{ include "suite.fullname" . }}-headless
  {{- else }}
  serviceName: {{ include "suite.fullname" . }}
  {{- end }}
  {{- end }}
  {{- if .Values.persistentVolume.enabled }}
  volumeClaimTemplates:
    - metadata:
        name: "pvc"
      spec:
        accessModes:
          - "ReadWriteOnce"
        {{- if .Values.storageClass }}
        storageClassName: "{{ .Values.storageClass }}"
        {{- else if .Values.global.storageClass }}
        storageClassName: "{{ .Values.global.storageClass }}"
        {{- end }}
        resources:
          requests:
            storage: "{{ .Values.persistentVolume.size }}"
  {{- end }}
  template:
    metadata:
      annotations:
      {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
      {{- end }}
        {{ if .Values.configMap.enabled }}
        checksum/configmap: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
        {{ end }}
        {{ if .Values.fluentBitSidecar.enabled }}
        checksum/fluentbit: {{ include (print $.Template.BasePath "/fluentbigconfig.yaml") . | sha256sum }}
        {{ end }}
      labels:
        {{- include "suite.selectorLabels" . | nindent 8 }}
        {{- if len .Values.global.commonSelectorLabels }}
        {{- toYaml .Values.global.commonSelectorLabels | nindent 8 }}
        {{- end }}
    spec:
      securityContext:
        fsGroup: {{ .Values.global.securityContext.runAsUser }}
        fsGroupChangePolicy: Always
      {{- with .Values.global.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      volumes:
      {{- if and (not .Values.persistentVolume.enabled) (.Values.persistentVolume.mountPath) }}
        - name: pvc
          emptyDir: {}
      {{- end }}
      {{- if .Values.fluentBitSidecar.enabled }}
        - name: {{ include "suite.fluentBitConfigName" . }}
          configMap:
            name: {{ include "suite.fluentBitConfigName" . }}
        - name: logs
          emptyDir:
            sizeLimit: 250Mi
      {{- end }}
      {{- with .Values.additionalVolumes }}
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.global.image.registry | default .Values.image.registry }}/{{ .Values.image.repository }}{{ if .Values.image.tag }}:{{ .Values.image.tag }}{{ else if .Values.image.digest }}@{{ .Values.image.digest }}{{ else }}:{{ .Chart.AppVersion }}{{ end }}"
          imagePullPolicy: {{ .Values.image.pullPolicy | default .Values.global.image.pullPolicy }}
          {{ include "suite.securityContext" . | nindent 10 }}
          {{- if .Values.command }}
          command:
          {{ toYaml .Values.command | nindent 12 }}
          {{- end }}
          {{- if .Values.configMap.enabled }}
          envFrom:
          - configMapRef:
              name: {{ include "suite.fullname" . }}-configmap
          {{- end }}
          {{- if or .Values.springApplicationJson.enabled (len .Values.extraEnv) }}
          env:
          - name: POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
          - name: POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          {{- if .Values.springApplicationJson.enabled }}
          - name: SPRING_APPLICATION_JSON
            value: {{ tpl (.Values.springApplicationJson.config | toJson | squote) . }}
          {{- end }}
          {{- if len .Values.extraEnv }}
          {{- range $key, $value := .Values.extraEnv }}
          - name: {{ $key }}
            value: {{ quote (tpl $value $) }}
          {{- end }}
          {{- end }}
          {{- end }}
          volumeMounts:
          {{- if or (.Values.persistentVolume.enabled) (.Values.persistentVolume.mountPath) }}
            - name: pvc
              mountPath: {{ .Values.persistentVolume.mountPath }}
          {{- end }}
          {{- if .Values.fluentBitSidecar.enabled }}
            - name: logs
              mountPath: {{ trimSuffix "/*.log" .Values.fluentBitSidecar.logPath }}
          {{- end }}
          {{- with .Values.additionalVolumeMounts }}
            {{- toYaml . | nindent 12 }}
          {{- end }}
          ports:
            {{- if .Values.service.headless.enabled }}
            {{- range .Values.service.headless.ports }}
            - name: {{ .targetPort }}
              containerPort: {{ default .port .containerPort }}
              protocol: TCP
            {{- end }}
            {{- else }}
            {{- range .Values.service.ports }}
            - name: {{ .targetPort }}
              containerPort: {{ default .port .containerPort }}
              protocol: TCP
            {{- end }}
            {{- end }}
          {{- if .Values.healthProbes }}
          {{ tpl (toYaml .Values.healthProbes) . | nindent 10 }}
          {{- end }}
          {{- $res := .Values.resources }}
          {{- if not .Values.global.resources.requests.enabled }}
            {{- $_ := set $res "requests" (dict "cpu" "50m" "memory" "128Mi") }}
          {{- end }}
          {{- if $res }}
          resources:
            {{- toYaml $res | nindent 12 }}
          {{- end }}
        {{- if and .Values.global.logging.enabled .Values.fluentBitSidecar.enabled }}
        - name: fluent-bit
          image: "{{ .Values.global.image.registry | default .Values.global.fluentBitSidecar.image.registry }}/{{ .Values.global.fluentBitSidecar.image.repository }}{{ if .Values.global.fluentBitSidecar.image.tag }}:{{ .Values.global.fluentBitSidecar.image.tag }}{{ else if .Values.global.fluentBitSidecar.image.digest }}@{{ .Values.global.fluentBitSidecar.image.digest }}{{ end }}"
          imagePullPolicy: {{ .Values.global.image.pullPolicy | default .Values.global.fluentBitSidecar.image.pullPolicy }}
          {{ include "suite.securityContext" . | nindent 10 }}
          resources:
            limits:
              memory: "256Mi"
              cpu: "250m"
              ephemeral-storage: "512Mi"
            requests:
              memory: "128Mi"
              cpu: "100m"
              ephemeral-storage: "512Mi"
          volumeMounts:
          - name: {{ include "suite.fluentBitConfigName" . }}
            mountPath: /fluent-bit/etc/
          - name: logs
            mountPath: /var/log/fluent-bit
        {{- end }}
        {{- if .Values.extraSidecars }}
          {{-  tpl (toYaml .Values.extraSidecars) . | nindent 8 }}
        {{- end }}
      {{- include "custom.nodeSelector" . | indent 6 }}
      {{- include "custom.affinity" . | indent 6 }}
      {{- include "custom.tolerations" . | indent 6 }}
{{- end }}
