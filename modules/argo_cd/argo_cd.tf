resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

  values = [file("${path.module}/values.yaml")]

  wait    = true
  timeout = 600
}

# Deploy Argo CD Applications chart after Argo CD itself is ready
resource "helm_release" "argocd_apps" {
  name      = "argocd-apps"
  chart     = "${path.module}/charts"
  namespace = var.namespace

  set = [
    {
      name  = "repositories[0].url"
      value = var.git_repo_url
    },
    {
      name  = "applications[0].source.repoURL"
      value = var.git_repo_url
    },
    {
      name  = "applications[0].source.targetRevision"
      value = var.git_repo_branch
    },
    {
      name  = "applications[0].destination.namespace"
      value = var.app_namespace
    },
  ]

  depends_on = [helm_release.argocd]
}

resource "helm_release" "prometheus_stack" {
  name             = "prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.prometheus_chart_version
  namespace        = "monitoring"
  create_namespace = true

  set = [
    {
      name  = "grafana.adminPassword"
      value = var.grafana_admin_password
    },
    {
      name  = "grafana.service.type"
      value = "ClusterIP"
    },
    # allow ServiceMonitors from all namespaces (picks up Jenkins metrics)
    {
      name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
      value = "false"
    },
    {
      name  = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
      value = "false"
    },
    {
      name  = "grafana.resources.requests.cpu"
      value = "100m"
    },
    {
      name  = "grafana.resources.requests.memory"
      value = "128Mi"
    },
    {
      name  = "grafana.resources.limits.cpu"
      value = "200m"
    },
    {
      name  = "grafana.resources.limits.memory"
      value = "256Mi"
    },
    {
      name  = "prometheus.prometheusSpec.resources.requests.cpu"
      value = "200m"
    },
    {
      name  = "prometheus.prometheusSpec.resources.requests.memory"
      value = "512Mi"
    },
    {
      name  = "prometheus.prometheusSpec.resources.limits.cpu"
      value = "500m"
    },
    {
      name  = "prometheus.prometheusSpec.resources.limits.memory"
      value = "1Gi"
    },
  ]

  wait    = true
  timeout = 600

  depends_on = [helm_release.argocd]
}
