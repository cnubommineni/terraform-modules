resource "kubernetes_namespace" "prometheus-namespace" {
  depends_on = [module.eks]
  count = var.create_prometheus_operator ? 1 : 0
  metadata {
    name = "monitoring"
  }
}

module "helm-chart-prometheus-operator" {
  source = "git@github.com:cloudrural/helm-charts-1.git"
}

resource "helm_release" "prometheus-operator" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = ".terraform/modules/microservice-infra./helm-chart-prometheus-operator/charts/kube-prometheus-stack"
  namespace  = "monitoring"
  values = [<<EOF
prometheus:
  ingress:
      enabled: true
      hosts: "${var.environment_name}-${var.region}-prometheus.securonix.net"
    EOF
  ]
}
