# Project: SkillPulse
# File: monitoring.tf
# Description: Installs Monitoring and Observability stack (Prometheus, Loki, OpenTelemetry) using Helm.

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# 1. Prometheus Stack (includes Grafana)
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "61.7.0"

  set {
    name  = "grafana.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  set {
    name  = "serverFiles.alerting_rules\\.yml.groups[0].name"
    value = "node-alerts"
  }

  set {
    name  = "serverFiles.alerting_rules\\.yml.groups[0].rules[0].alert"
    value = "HighCPUUsage"
  }

  set {
    name  = "serverFiles.alerting_rules\\.yml.groups[0].rules[0].expr"
    value = var.environment == "prod" ? "100 - (avg by(instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100) > 80" : "100 - (avg by(instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100) > 95"
  }
}

# 2. Loki Stack for Logging
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "2.10.2"

  set {
    name  = "loki.persistence.enabled"
    value = "true"
  }

  set {
    name  = "promtail.enabled"
    value = "true"
  }

  set {
    name  = "promtail.extraArgs[0]"
    value = "-client.external-labels=env=${var.environment}"
  }
}

# 3. OpenTelemetry Operator/Collector
resource "helm_release" "opentelemetry" {
  name       = "opentelemetry-operator"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-operator"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "0.66.0"

  set {
    name  = "admissionWebhooks.certManager.enabled"
    value = "false" # Set to true if cert-manager is installed
  }
}
