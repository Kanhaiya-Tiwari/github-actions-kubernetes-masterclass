
# Description: Installs ArgoCD into the EKS cluster using Helm.

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "7.7.0"

 set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}
