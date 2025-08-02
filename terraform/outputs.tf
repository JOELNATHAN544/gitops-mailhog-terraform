output "argocd_server_url" {
  description = "Argo CD server URL"
  value       = helm_release.argocd.status.load_balancer_ingress[0].hostname
}
