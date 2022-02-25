resource "kubernetes_namespace" "jenkins-namespace" {
  count = var.create_jenkins ? 1 : 0
  depends_on = [module.eks]
  metadata {
    name = "jenkins"
  }
}

resource "kubernetes_storage_class" "jenkins-pv-storage-class" {
  count = var.create_jenkins ? 1 : 0
  storage_provisioner = "kubernetes.io/no-provisioner"
  metadata {
    name = "jenkins-storage-class"
  }
  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "kubernetes_persistent_volume" "jenkins-pv" {
  count = var.create_jenkins ? 1 : 0
  metadata {
    name = "jenkins-pv"
  }
  spec {
    storage_class_name = "jenkins-storage-class"
    access_modes       = ["ReadWriteOnce"]
    capacity = {
      storage = "40Gi"
    }
    persistent_volume_source {
      host_path {
        path = "/jenkins"
      }
    }
    persistent_volume_reclaim_policy = "Retain"
  }
}

resource "kubernetes_persistent_volume_claim" "jenkins-pvc" {
  count = var.create_jenkins ? 1 : 0
  depends_on = [kubernetes_persistent_volume.jenkins-pv]
  metadata {
    name      = "jenkins-pvc"
    namespace = "jenkins"
  }
  spec {
    storage_class_name = "jenkins-storage-class"
    access_modes       = ["ReadWriteOnce"]
    volume_name        = kubernetes_persistent_volume.jenkins-pv[count.index].metadata.0.name
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

module "helm-chart-jenkins" {
  source = "git@bitbucket.org:securonixsnypr/helm-chart-jenkins.git"
}


resource "helm_release" "jenkins" {
  count = var.create_jenkins ? 1 : 0
  chart     = ".terraform/modules/cicd-infra.helm-chart-jenkins/charts/jenkins"
  name      = "jenkins"
  namespace = "jenkins"
  values = [<<EOF
    controller:
      numExecutors: 1
      adminUser: "admin"
      adminPassword: "DevOps@123"
      installPlugins:
        - job-dsl:1.77
        - xml-job-to-job-dsl:0.1.12
        - ace-editor:1.1
        - amazon-ecr:1.6
        - ansicolor:1.0.0
        - antisamy-markup-formatter:2.1
        - apache-httpcomponents-client-4-api:4.5.13-1.0
        - atlassian-bitbucket-server-integration:2.1.3
        - authentication-tokens:1.4
        - aws-credentials:1.29
        - aws-java-sdk:1.11.995
        - bitbucket:1.1.29
        - blueocean:1.24.7
        - blueocean-autofavorite:1.2.4
        - blueocean-bitbucket-pipeline:1.24.7
        - blueocean-commons:1.24.7
        - blueocean-config:1.24.7
        - blueocean-core-js:1.24.7
        - blueocean-dashboard:1.24.7
        - blueocean-display-url:2.4.1
        - blueocean-events:1.24.7
        - blueocean-git-pipeline:1.24.7
        - blueocean-github-pipeline:1.24.7
        - blueocean-i18n:1.24.7
        - blueocean-jwt:1.24.7
        - blueocean-personalization:1.24.7
        - blueocean-pipeline-api-impl:1.24.7
        - blueocean-pipeline-editor:1.24.7
        - blueocean-pipeline-scm-api:1.24.7
        - blueocean-rest:1.24.7
        - blueocean-rest-impl:1.24.7
        - blueocean-web:1.24.7
        - bootstrap4-api:4.6.0-3
        - bootstrap5-api:5.0.1-2
        - bouncycastle-api:2.20
        - branch-api:2.6.4
        - caffeine-api:2.9.1-23.v51c4e2c879c8
        - checks-api:1.7.0
        - cloudbees-bitbucket-branch-source:2.9.9
        - cloudbees-folder:6.15
        - command-launcher:1.6
        - config-file-provider:3.8.0
        - configuration-as-code:1.51
        - credentials:2.5
        - credentials-binding:1.26
        - display-url-api:2.3.5
        - docker-commons:1.17
        - docker-workflow:1.26
        - durable-task:1.37
        - echarts-api:5.1.2-2
        - email-ext:2.83
        - favorite:2.3.3
        - font-awesome-api:5.15.3-3
        - git:4.7.2
        - git-client:3.7.2
        - git-server:1.9
        - github:1.33.1
        - github-api:1.123
        - github-branch-source:2.11.1
        - h2-api:1.4.199
        - handlebars:3.0.8
        - handy-uri-templates-2-api:2.1.8-1.0
        - htmlpublisher:1.25
        - jackson2-api:2.12.3
        - javadoc:1.6
        - jaxb:2.3.0.1
        - jdk-tool:1.5
        - jenkins-design-language:1.24.7
        - jira:3.5
        - jjwt-api:0.11.2-9.c8b45b8bb173
        - jobConfigHistory:2.27
        - jquery-detached:1.2.1
        - jquery3-api:3.6.0-1
        - jsch:0.1.55.2
        - junit:1.51
        - kubernetes:1.30.0
        - kubernetes-client-api:5.4.1
        - kubernetes-credentials:0.9.0
        - lockable-resources:2.11
        - mailer:1.34
        - matrix-auth:2.6.7
        - matrix-project:1.19
        - maven-plugin:3.12
        - mercurial:2.15
        - metrics:4.0.2.8
        - momentjs:1.1.1
        - okhttp-api:3.14.9
        - pipeline-build-step:2.13
        - pipeline-graph-analysis:1.11
        - pipeline-input-step:2.12
        - pipeline-maven:3.10.0
        - pipeline-milestone-step:1.3.2
        - pipeline-model-api:1.8.5
        - pipeline-model-definition:1.8.5
        - pipeline-model-extensions:1.8.5
        - pipeline-rest-api:2.19
        - pipeline-stage-step:2.5
        - pipeline-stage-tags-metadata:1.8.5
        - pipeline-stage-view:2.19
        - pipeline-utility-steps:2.8.0
        - plain-credentials:1.7
        - plugin-util-api:2.3.0
        - popper-api:1.16.1-2
        - popper2-api:2.5.4-2
        - pubsub-light:1.16
        - rebuild:1.32
        - resource-disposer:0.16
        - saml:2.0.7
        - scm-api:2.6.4
        - script-security:1.77
        - slack:2.48
        - snakeyaml-api:1.29.1
        - sonar:2.13.1
        - sse-gateway:1.24
        - ssh-credentials:1.19
        - sshd:3.0.3
        - structs:1.23
        - timestamper:1.13
        - token-macro:2.15
        - trilead-api:1.0.13
        - variant:1.4
        - windows-slaves:1.8
        - workflow-aggregator:2.6
        - workflow-api:2.46
        - workflow-basic-steps:2.23
        - workflow-cps:2.92
        - workflow-cps-global-lib:2.21
        - workflow-durable-task-step:2.39
        - workflow-job:2.41
        - workflow-multibranch:2.26
        - workflow-remote-loader:1.5
        - workflow-scm-step:2.13
        - workflow-step-api:2.23
        - workflow-support:3.8
        - ws-cleanup:0.39
      ingress:
        enabled: true
        apiVersion: "networking.k8s.io/v1"
        hostName: jenkins.securonix.net
        ingressClassName: nginx
        kubernetes.io/ingress.class: nginx
      csrf:
        defaultCrumbIssuer:
          enabled: false
    persistence:
      enabled: true
      existingClaim: jenkins-pvc
    EOF
  ]
}