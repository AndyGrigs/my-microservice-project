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

  set {
    name  = "applications[0].source.repoURL"
    value = var.git_repo_url
  }

  set {
    name  = "applications[0].source.targetRevision"
    value = var.git_repo_branch
  }

  set {
    name  = "applications[0].destination.namespace"
    value = var.app_namespace
  }

  depends_on = [helm_release.argocd]
}
