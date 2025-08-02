output "argocd_server_url" {
  description = "Argo CD server URL"
  value       = data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname
}
