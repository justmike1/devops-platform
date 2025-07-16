{{- define "suite.fluentbitconfigtemplate" }}
{{- if .Values.fluentBitSidecar.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "suite.fluentBitConfigName" . }}
  labels:
    {{- include "suite.labels" . | nindent 4 }}
    {{- if len .Values.global.commonLabels }}
    {{- toYaml .Values.global.commonLabels | nindent 4 }}
    {{- end }}
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush               5
        Log_Level           info
        Daemon              off
        Parsers_File        parsers.conf
        scheduler.base      3
        scheduler.cap       120

    [INPUT]
        Name                tail
        Tag                 kube.var.log.fluent-bit
        Path                /var/log/fluent-bit/*.log
        Parser              ecs_json
        Buffer_Chunk_Size   1MB
        Buffer_Max_Size     5MB
        Skip_Long_Lines     On
        Read_From_Head      On
        Refresh_Interval    5

    [FILTER]
        # Normalize fields to ECS conventions
        Name                modify
        Match               *
        Rename              log_level             log.level
        Rename              service_name          service.name
        Rename              log_logger            log.logger
        Rename              pod_name              pod.name
        Rename              process_pid           process.pid
        Rename              process_thread_name   process.thread.name

    [OUTPUT]
        Name                opensearch
        Match               *
        Host                opensearch
        HTTP_User           admin
        HTTP_Passwd         {{ .Values.global.opensearch.token }}
        Type                client
        Port                9200
        Index               {{ include "suite.fullname" . }}
        Buffer_Size         5MB
        TLS                 Off
        TLS.verify          Off
        Retry_Limit         no_limits
        Replace_Dots        On
        Suppress_Type_Name  On
        Compress            gzip
        Generate_ID         On
        Trace_Error         On

  parsers.conf: |
    [PARSER]
        Name          ecs_json
        Format        json
        Time_Key      @timestamp
        Time_Keep     On
        Time_Format   %Y-%m-%dT%H:%M:%S.%L%z
{{- end }}
{{- end }}