resource "kubernetes_namespace" "sonar-namespace" {
  count = var.create_sonar ? 1 : 0
  depends_on = [module.eks]
  metadata {
    name = "sonar"
  }
}

resource "kubernetes_storage_class" "sonar-pv-storage-class" {
  count = var.create_sonar ? 1 : 0
  storage_provisioner = "kubernetes.io/no-provisioner"
  metadata {
    name = "sonar-storage-class"
  }
  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "kubernetes_persistent_volume" "sonar-pv" {
  count = var.create_sonar ? 1 : 0
  metadata {
    name = "sonar-pv"
  }
  spec {
    storage_class_name = "sonar-storage-class"
    access_modes       = ["ReadWriteOnce"]
    capacity = {
      storage = "40Gi"
    }
    persistent_volume_source {
      host_path {
        path = "/sonarqube"
      }
    }
    persistent_volume_reclaim_policy = "Retain"
  }
}

resource "kubernetes_persistent_volume_claim" "sonar-pvc" {
  count = var.create_sonar ? 1 : 0
  depends_on = [kubernetes_persistent_volume.sonar-pv]
  metadata {
    name      = "sonar-pvc"
    namespace = "sonar"
  }
  spec {
    storage_class_name = "sonar-storage-class"
    access_modes       = ["ReadWriteOnce"]
    volume_name        = kubernetes_persistent_volume.sonar-pv[count.index].metadata.0.name
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

module "helm-chart-sonarqube" {
  source = "git@bitbucket.org:securonixsnypr/helm-chart-sonarqube.git"
}

// create helm sonar
resource "helm_release" "sonar" {
  count = var.create_sonar ? 1 : 0
  //repository = "https://github.com/sonatype/helm3-charts/"
  chart     = ".terraform/modules/cicd-infra.helm-chart-sonarqube/sonarqube/charts/sonarqube"
  name      = "sonar"
  namespace = "sonar"
  dependency_update = true
  values    = [<<EOF
    ingress:
      enabled: true
      annotations:
        kubernetes.io/ingress.class: nginx
      hosts:
        - name: sonar.securonix.net
    persistence:
      enabled: true
      existingClaim: sonar-pvc
    EOF
  ]
}
