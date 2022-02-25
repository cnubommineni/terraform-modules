
resource "kubernetes_namespace" "ingress-nginx-namespace" {
  depends_on = [module.eks]
  count = var.create_ingress_nginx ? 1 : 0
  metadata {
    name = "ingress-nginx"
  }
}

module "helm-chart-ingress-nginx" {
  source = "git@bitbucket.org:securonixsnypr/helm-chart-ingress-nginx.git"
}

resource "helm_release" "ingress-controller" {
  count = var.create_ingress_nginx ? 1 : 0
  depends_on = [kubernetes_namespace.ingress-nginx-namespace]
  chart      = ".terraform/modules/cicd-infra.helm-chart-ingress-nginx/charts/ingress-nginx"
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  values = [<<EOF
    controller:
      config:
        whitelist-source-range: "0.0.0.0/0"
        proxy-body-size: "2048m"
        client-body-buffer-size: "2048m"
        use-proxy-protocol: "true"
      service:
        targetPorts:
          https: 80
        annotations:
          service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "60"
          service.beta.kubernetes.io/aws-load-balancer-ssl-cert: ${local.ssl_cert}
          service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "tcp"
          service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
          service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: "*"
    EOF
  ]
}

locals {
  ssl_cert = var.ssl_cert_arn
}
