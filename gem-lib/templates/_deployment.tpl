{{- define "gem-lib.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ printf "%s-deployment" .Values.name }}
  namespace: {{ .Common.namespace }}
  labels:
    app: {{ .Values.name }}
spec:
  replicas: {{ .Common.replicas }}
  selector:
    matchLabels:
      app: {{ .Values.name }}
  template:
    metadata:
      labels:
        app: {{ .Values.name }}
      annotations:
{{- with .Common.podTemplate.metadata.annotations }}
{{ toYaml . | indent 8 }}
{{- end }}
    spec:
      containers:
        - name: {{ .Values.name }}
          image: {{ .Values.image | default (printf "%s/%s:latest" .Common.dockerHub .Values.name) }}
          {{- if .Values.image }}
          imagePullPolicy: Never
          {{- else }}
          imagePullPolicy: Always
          {{- end }}
          ports:
            - containerPort: {{ .Common.port }}
          startupProbe:
            httpGet:
              path: /actuator/health
              port: {{ .Common.port }}
            initialDelaySeconds: {{ .Common.startupProbe.initialDelaySeconds }}
            periodSeconds: {{ .Common.startupProbe.periodSeconds }}
            failureThreshold: {{ .Common.startupProbe.failureThreshold }}
          livenessProbe:
            httpGet:
              path: /actuator/health
              port: {{ .Common.port }}
            failureThreshold: {{ .Common.livenessProbe.failureThreshold }}
            periodSeconds: {{ .Common.livenessProbe.periodSeconds }}

          {{- if .Values.env }}
          env:
            {{- range $env := .Values.env }}
            - name: {{ $env.name }}
              {{- if $env.secretKeyRef }}
              valueFrom:
                secretKeyRef:
                  name: {{ $env.secretKeyRef.name }}
                  key: {{ $env.secretKeyRef.key }}
              {{- else if $env.configMapKeyRef }}
              valueFrom:
                configMapKeyRef:
                  name: {{ $env.configMapKeyRef.name }}
                  key: {{ $env.configMapKeyRef.key }}
              {{- end }}
            {{- end }}
          {{- end }}

---

apiVersion: v1
kind: Service
metadata:
  name: {{ printf "%s-service" .Values.name }}
  namespace: {{ .Common.namespace }}
spec:
  type: {{ .Values.type | default "ClusterIP" }}
  selector:
    app: {{ .Values.name }}
  ports:
    - protocol: TCP
      port: {{ .Common.port }}
      targetPort: {{ .Common.servicePort }}
      {{- if eq .Values.type "NodePort" }}
      nodePort: {{ .Values.nodePort }}
      {{- end }}
{{- end -}}
