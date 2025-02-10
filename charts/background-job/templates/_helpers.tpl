{{/*
Expand the name of the chart.
*/}}
{{- define "background-job.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "background-job.fullname" -}}
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
{{- define "background-job.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "background-job.labels" -}}
helm.sh/chart: {{ include "background-job.chart" . }}
{{ include "background-job.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "background-job.selectorLabels" -}}
app.kubernetes.io/name: {{ include "background-job.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "background-job.serviceAccountName" -}}
{{- if .Values.pod.serviceAccount.create }}
{{- default (include "background-job.fullname" .) .Values.pod.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.pod.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Pod template
*/}}
{{- define "background-job.podTemplate" -}}
metadata:
  labels:
    {{- include "background-job.selectorLabels" . | nindent 4 }}
    {{- with .Values.pod.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with .Values.pod.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with .Values.pod.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if .Values.pod.serviceAccount.create }}
  serviceAccountName: {{ include "background-job.serviceAccountName" . }}
  {{- end }}
  containers:
    - name: {{ .Chart.Name }}
      image: "{{ .Values.pod.image.repository }}:{{ .Values.pod.image.tag }}"
      imagePullPolicy: {{ .Values.pod.image.pullPolicy }}
      {{- with .Values.command }}
      command:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.args }}
      args:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.env }}
      env:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.volumeMounts }}
      volumeMounts:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.pod.resources }}
      resources:
        {{- toYaml . | nindent 8 }}
      {{- end }}
  {{- with .Values.volumes }}
  volumes:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.pod.nodeSelector }}
  nodeSelector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.pod.affinity }}
  affinity:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.pod.tolerations }}
  tolerations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }} 