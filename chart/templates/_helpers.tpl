{{/*
Expand the name of the chart.
*/}}
{{- define "alfalfa.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "alfalfa.fullname" -}}
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
MongoDB connection host
*/}}
{{- define "alfalfa.mongodb.host" -}}
{{- .Values.config.mongodb.host | default (printf "%s-mongodb" (include "alfalfa.fullname" .)) -}}
{{- end }}

{{/*
MongoDB connection port
*/}}
{{- define "alfalfa.mongodb.port" -}}
{{- .Values.config.mongodb.port | default (.Values.mongodb.service.ports.mongodb | default 27017) -}}
{{- end }}

{{/*
MongoDB database name
*/}}
{{- define "alfalfa.mongodb.database" -}}
{{- .Values.config.mongodb.database |  default "alfalfa" -}}
{{- end }}

{{/*
MongoDB user
*/}}
{{- define "alfalfa.mongodb.user" -}}
{{- .Values.config.mongodb.auth.username | default "" -}}
{{- end }}

{{/*
MongoDB password
*/}}
{{- define "alfalfa.mongodb.password" -}}
{{- .Values.config.mongodb.auth.password | default "" -}}
{{- end }}

{{/*
MongoDB connection URL
*/}}
{{- define "alfalfa.mongodb.url" -}}
{{- if .Values.config.mongodb.connectionUrl -}}
{{ .Values.config.mongodb.connectionUrl }}
{{- else if .Values.config.mongodb.auth.enabled -}}
mongodb://{{ include "alfalfa.mongodb.user" . }}:{{ include "alfalfa.mongodb.password" . }}@{{ include "alfalfa.mongodb.host" . }}:{{ include "alfalfa.mongodb.port" . }}/{{ include "alfalfa.mongodb.database" . }}?authSource=admin
{{- else -}}
mongodb://{{ include "alfalfa.mongodb.host" . }}:{{ include "alfalfa.mongodb.port" . }}/{{ include "alfalfa.mongodb.database" . }}
{{- end -}}
{{- end }}

{{/*
Common labels
*/}}
{{- define "alfalfa.labels" -}}
helm.sh/chart: {{ include "alfalfa.chart" . }}
{{ include "alfalfa.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "alfalfa.selectorLabels" -}}
app.kubernetes.io/name: {{ include "alfalfa.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Chart label
*/}}
{{- define "alfalfa.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
S3/MinIO host
*/}}
{{- define "alfalfa.s3.host" -}}
{{- .Values.config.s3.host | default (printf "%s-minio" (include "alfalfa.fullname" .)) -}}
{{- end }}

{{/*
S3/MinIO port
*/}}
{{- define "alfalfa.s3.port" -}}
{{- if .Values.config.s3.port -}}
{{ .Values.config.s3.port }}
{{- else if .Values.minio.enabled -}}
{{ .Values.minio.service.ports.api | default 9000 }}
{{- else -}}
9000
{{- end -}}
{{- end }}

{{/*
S3 bucket name
*/}}
{{- define "alfalfa.s3.bucket" -}}
{{- if .Values.minio.enabled -}}
{{ .Values.minio.defaultBuckets | default "alfalfa" }}
{{- else -}}
{{ .Values.config.s3.bucket }}
{{- end -}}
{{- end }}

{{/*
S3 region
*/}}
{{- define "alfalfa.s3.region" -}}
{{- if .Values.minio.enabled -}}
us-east-1
{{- else -}}
{{ .Values.config.s3.region }}
{{- end -}}
{{- end }}

{{/*
S3 URL (internal)
*/}}
{{- define "alfalfa.s3.url" -}}
{{- if .Values.config.s3.secure -}}
https://{{ include "alfalfa.s3.host" . }}:{{ include "alfalfa.s3.port" . }}
{{- else -}}
http://{{ include "alfalfa.s3.host" . }}:{{ include "alfalfa.s3.port" . }}
{{- end -}}
{{- end }}

{{/*
S3 external URL (for browser access)
*/}}
{{- define "alfalfa.s3.externalUrl" -}}
{{- if and .Values.minio.enabled .Values.ingress.enabled .Values.ingress.hosts.minio.host -}}
{{- if .Values.ingress.hosts.minio.https -}}
https://{{ .Values.ingress.hosts.minio.host }}
{{- else -}}    
http://{{ .Values.ingress.hosts.minio.host }}
{{- end -}}
{{- else -}}
{{ .Values.config.s3.externalUrl | default (include "alfalfa.s3.url" .) }}
{{- end -}}
{{- end }}

{{/*
S3 access key
*/}}
{{- define "alfalfa.s3.accessKey" -}}
{{ .Values.config.s3.auth.accessKey | default "" }}
{{- end }}

{{/*
S3 secret key
*/}}
{{- define "alfalfa.s3.secretKey" -}}
{{ .Values.config.s3.auth.secretKey | default "" }}
{{- end }}

{{/*
Redis host
*/}}
{{- define "alfalfa.redis.host" -}}
{{- .Values.config.redis.host | default (printf "%s-redis" (include "alfalfa.fullname" .)) -}}
{{- end }}

{{/*
Redis port
*/}}
{{- define "alfalfa.redis.port" -}}
{{- .Values.config.redis.port | default (.Values.redis.service.ports.redis | default 6379) -}}
{{- end }}

{{/*
Redis password
*/}}
{{- define "alfalfa.redis.password" -}}
{{ .Values.config.redis.auth.password | default "" }}
{{- end }}

{{/*
Redis URL
*/}}
{{- define "alfalfa.redis.url" -}}
{{- if .Values.config.redis.connectionUrl -}}
{{ .Values.config.redis.connectionUrl }}
{{- else if .Values.config.redis.auth.enabled -}}
redis://:{{ include "alfalfa.redis.auth.password" . }}@{{ include "alfalfa.redis.host" . }}:{{ include "alfalfa.redis.port" . }}
{{- else -}}
redis://{{ include "alfalfa.redis.host" . }}:{{ include "alfalfa.redis.port" . }}
{{- end -}}
{{- end }}


{{/*
InfluxDB host
*/}}
{{- define "alfalfa.influxdb.host" -}}
{{- .Values.config.influxdb.host | default (printf "%s-influxdb" (include "alfalfa.fullname" .)) -}}
{{- end }}

{{/* InfluxDB port */}}
{{- define "alfalfa.influxdb.port" -}}
{{- .Values.config.influxdb.port | default (.Values.influxdb.service.ports.db_port | default 8086) -}}
{{- end }}

{{/* InfluxDB database name */}}
{{- define "alfalfa.influxdb.database" -}}
{{- .Values.config.influxdb.database | default "alfalfa" -}}
{{- end }}

{{/* InfluxDB username */}}
{{- define "alfalfa.influxdb.username" -}}
{{- .Values.config.influxdb.auth.username | default "admin" -}}
{{- end }}

{{/* InfluxDB password */}}
{{- define "alfalfa.influxdb.password" -}}
{{- .Values.config.influxdb.auth.password | default "changeme-influxdb-password" -}}
{{- end }}

{{/*
Grafana admin username
*/}}
{{- define "alfalfa.grafana.username" -}}
{{- .Values.config.grafana.auth.username | default "admin" -}}
{{- end }}

{{/*
Grafana admin password
*/}}
{{- define "alfalfa.grafana.password" -}}
{{- .Values.config.grafana.auth.password | default "changeme-grafana-password" -}}
{{- end }}