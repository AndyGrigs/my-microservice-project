output "jenkins_namespace" {
  description = "Kubernetes namespace where Jenkins is deployed"
  value       = var.namespace
}

output "jenkins_service_name" {
  description = "Kubernetes service name for Jenkins"
  value       = "jenkins"
}

output "jenkins_admin_password_command" {
  description = "Command to retrieve Jenkins admin password from Kubernetes secret"
  value       = "kubectl get secret --namespace ${var.namespace} jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 --decode"
}
