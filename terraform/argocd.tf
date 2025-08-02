resource "helm_release" "argocd" {
  name            = "argocd"
  repository      = "https://argoproj.github.io/argo-helm"
  chart           = "argo-cd"
  namespace       = kubernetes_namespace.argocd.metadata[0].name
  version         = var.argocd_chart_version
  timeout         = 600
  recreate_pods   = true

  values = [
    file("${path.module}/argocd-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  depends_on = [
    helm_release.argocd
  ]
}
