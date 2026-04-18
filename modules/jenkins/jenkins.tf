resource "helm_release" "jenkins" {
  name             = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

  values = [templatefile("${path.module}/values.yaml", {
    jenkins_admin_password = var.jenkins_admin_password
    git_repo_url           = var.git_repo_url
  })]

  # Wait until Jenkins is fully running before Terraform completes
  wait    = true
  timeout = 600
}

# Kubernetes Secret with ECR credentials for Kaniko
resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-credentials"
    namespace = var.namespace
  }

  data = {
    # config.json format required by Kaniko
    "config.json" = jsonencode({
      credHelpers = {
        "${split("/", var.ecr_repository_url)[0]}" = "ecr-login"
      }
    })
  }

  depends_on = [helm_release.jenkins]
}
