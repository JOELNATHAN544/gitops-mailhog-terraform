resource "helm_release" "argocd" {
  name            = "argocd"
  repository      = "https://argoproj.github.io/argo-helm"
  chart           = "argo-cd"
  version         = var.argocd_chart_version
  timeout         = 600

  namespace        = var.argocd_namespace
  create_namespace = true

  values = [
    file("${path.module}/argocd-values.yaml")
  ]
}

data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = var.argocd_namespace
  }

  depends_on = [
    helm_release.argocd
  ]
}