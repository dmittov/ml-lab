{{- define "mlflow.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "backup.destination" -}}
{{- printf "%s-%s" .Values.pg.backup.destination "backup" -}}
{{- end -}}