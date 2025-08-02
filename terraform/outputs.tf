output "argocd_server_node_port" {
  description = "Argo CD server NodePort"
  value       = data.kubernetes_service.argocd_server.spec[0].port[0].node_port
}
