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
    value = "ClusterIP"
  }

  set {
    name  = "configs.params.server\\.basehref"
    value = "/argocd"
  }

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }
  set {
    name  = "server.ingress.ingressClassName"
    value = "nginx"
  }
  set {
    name  = "server.ingress.paths"
    value = "{/argocd}"
  }
  set {
    name  = "server.ingress.https"
    value = "false"
  }
}

# Automate project deployment after ArgoCD is ready
resource "null_resource" "project_automation" {
  depends_on = [helm_release.argocd]

  provisioner "local-exec" {
    command = "bash ../../../deploy.sh ${var.environment} --post-only"
  }
}
