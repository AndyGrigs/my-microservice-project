output "argocd_namespace" {
  description = "Namespace where Argo CD is deployed"
  value       = var.namespace
}

output "argocd_initial_password_command" {
  description = "Command to get the initial Argo CD admin password"
  value       = "kubectl get secret argocd-initial-admin-secret -n ${var.namespace} -o jsonpath='{.data.password}' | base64 --decode"
}

output "argocd_url_command" {
  description = "Command to get the Argo CD LoadBalancer URL"
  value       = "kubectl get svc argocd-server -n ${var.namespace} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "grafana_access_command" {
  description = "Port-forward command for Grafana"
  value       = "kubectl port-forward svc/prometheus-stack-grafana 3000:80 -n monitoring"
}

output "prometheus_access_command" {
  description = "Port-forward command for Prometheus"
  value       = "kubectl port-forward svc/prometheus-stack-kube-prom-prometheus 9090:9090 -n monitoring"
}
