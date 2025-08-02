resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = var.argocd_chart_version

  values = [
    file("${path.module}/argocd-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}
