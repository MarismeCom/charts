{{- define "oxidized.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "oxidized.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "oxidized.name" . -}}
{{- end -}}
{{- end -}}

{{- define "oxidized.namespace" -}}
{{- default .Release.Namespace .Values.namespace.name -}}
{{- end -}}

{{- define "oxidized.labels" -}}
app.kubernetes.io/name: {{ include "oxidized.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: network-automation
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}{{ if .Values.commonLabels }}
{{ toYaml .Values.commonLabels }}{{ end }}
{{- end -}}

{{- define "oxidized.selectorLabels" -}}
app.kubernetes.io/name: {{ include "oxidized.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "oxidized.configMapName" -}}
{{- if .Values.config.existingConfigmap -}}
{{ .Values.config.existingConfigmap }}
{{- else -}}
{{ include "oxidized.fullname" . }}-config
{{- end -}}
{{- end -}}

{{- define "oxidized.image" -}}
{{- $registry := .Values.image.registry | default .Values.global.imageRegistry -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry .Values.image.repository .Values.image.tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- end -}}
{{- end -}}

{{- define "oxidized.initImage" -}}
{{- $registry := .Values.initImage.registry | default .Values.global.imageRegistry -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry .Values.initImage.repository .Values.initImage.tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.initImage.repository .Values.initImage.tag -}}
{{- end -}}
{{- end -}}

{{- define "oxidized.testImage" -}}
{{- $registry := .Values.tests.image.registry | default .Values.global.imageRegistry -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry .Values.tests.image.repository .Values.tests.image.tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.tests.image.repository .Values.tests.image.tag -}}
{{- end -}}
{{- end -}}

{{- define "oxidized.imagePullSecrets" -}}
{{- $pullSecrets := list -}}
{{- range .Values.global.imagePullSecrets }}
{{- if kindIs "string" . }}
{{- $pullSecrets = append $pullSecrets (dict "name" .) -}}
{{- else }}
{{- $pullSecrets = append $pullSecrets . -}}
{{- end }}
{{- end }}
{{- range .Values.imagePullSecrets }}
{{- if kindIs "string" . }}
{{- $pullSecrets = append $pullSecrets (dict "name" .) -}}
{{- else }}
{{- $pullSecrets = append $pullSecrets . -}}
{{- end }}
{{- end }}
{{- if $pullSecrets }}
{{- toYaml $pullSecrets -}}
{{- end }}
{{- end -}}

{{- define "oxidized.pvcName" -}}
{{- if .Values.persistence.existingClaim -}}
{{ .Values.persistence.existingClaim }}
{{- else -}}
{{ include "oxidized.fullname" . }}-data
{{- end -}}
{{- end -}}

{{- define "oxidized.storageClass" -}}
{{- $storageClass := .Values.persistence.storageClass | default .Values.persistence.storageClassName | default .Values.global.defaultStorageClass | default .Values.global.storageClass -}}
{{- if $storageClass -}}
{{- if eq $storageClass "-" -}}
{{- printf "storageClassName: \"\"" -}}
{{- else -}}
{{- printf "storageClassName: %s" ($storageClass | quote) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "oxidized.sshSecretName" -}}
{{- if .Values.sshSecret.existingSecret -}}
{{ .Values.sshSecret.existingSecret }}
{{- else if .Values.sshSecret.name -}}
{{ .Values.sshSecret.name }}
{{- else -}}
{{ include "oxidized.fullname" . }}-ssh-keys
{{- end -}}
{{- end -}}

{{- define "oxidized.runtimeSecretName" -}}
{{- if .Values.runtimeSecret.existingSecret -}}
{{ .Values.runtimeSecret.existingSecret }}
{{- else if .Values.runtimeSecret.name -}}
{{ .Values.runtimeSecret.name }}
{{- else -}}
{{ include "oxidized.fullname" . }}-runtime
{{- end -}}
{{- end -}}

{{- define "oxidized.serviceAccountName" -}}
{{- if .Values.serviceAccount.name -}}
{{ .Values.serviceAccount.name }}
{{- else if .Values.serviceAccount.create -}}
{{ include "oxidized.fullname" . }}
{{- else -}}
default
{{- end -}}
{{- end -}}
