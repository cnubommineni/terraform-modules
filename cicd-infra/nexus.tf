
// create blob bucket

resource "aws_s3_bucket" "nexus-blob-store" {
  count = var.create_nexus ? 1 : 0
  bucket = local.nexus_blob_store_bucket_name
  acl = "private"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  replication_configuration {
    role = aws_iam_role.nexus-blob-store-replication[count.index].arn
    rules {
      status = "Enabled"

      destination {
        bucket        = aws_s3_bucket.nexus-blob-store-replica[count.index].arn
        storage_class = "STANDARD_IA"
      }
    }
  }

  tags = {
    Name = "nexus-blob-store"
    Environment = var.environment_name
  }
}

resource "aws_s3_bucket_policy" "nexus-blob-store-policy" {
  count = var.create_nexus ? 1 : 0
  bucket = aws_s3_bucket.nexus-blob-store[count.index].id
  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "S3BucketPolicy"
    Statement = [
      {
        Sid       = "DeleteProtection"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:DeleteBucket"
        Resource = [
          "${aws_s3_bucket.nexus-blob-store[count.index].arn}"
        ]
      },
    ]
  })
}

resource "aws_s3_bucket" "nexus-blob-store-replica" {
  provider = aws.s3-backup-provider
  bucket = local.nexus_blob_store_replica_bucket_name
  count = var.create_nexus ? 1 : 0
  acl = "private"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  tags = {
    Name = "nexus-blob-store-replica"
    Environment = var.environment_name
  }
}

resource "aws_s3_bucket_policy" "nexus-blob-store-replica-policy" {
  count = var.create_nexus ? 1 : 0
  bucket = aws_s3_bucket.nexus-blob-store-replica[count.index].id
  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "S3BucketPolicy"
    Statement = [
      {
        Sid       = "DeleteProtection"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:DeleteBucket"
        Resource = [
          "${aws_s3_bucket.nexus-blob-store-replica[count.index].arn}"
        ]
      },
    ]
  })
}

resource "aws_iam_role" "nexus-blob-store-replication" {
  name = "nexus-blob-store-replication"
  count = var.create_nexus ? 1 : 0

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "nexus-blob-store-replication" {
  name = "nexus-blob-store-replication"
  count = var.create_nexus ? 1 : 0

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.nexus-blob-store[count.index].arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
         "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.nexus-blob-store[count.index].arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.nexus-blob-store-replica[count.index].arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "nexus-blob-store-replication" {
  count = var.create_nexus ? 1 : 0
  role       = aws_iam_role.nexus-blob-store-replication[count.index].name
  policy_arn = aws_iam_policy.nexus-blob-store-replication[count.index].arn
}

// user for nexus blob access
resource "aws_iam_user" "nexus-service-user" {
  count = var.create_nexus ? 1 : 0
  name = "${var.environment_name}-nexus-service-user"
}
resource "aws_iam_user_policy" "nexus-service-policy" {
  count = var.create_nexus ? 1 : 0
  user = aws_iam_user.nexus-service-user[count.index].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "kubernetes_namespace" "nexus-namespace" {
  count = var.create_nexus ? 1 : 0
  depends_on = [module.eks]
  metadata {
    name = "nexus"
  }
}

resource "kubernetes_storage_class" "nexus-pv-storage-class" {
  count = var.create_nexus ? 1 : 0
  storage_provisioner = "kubernetes.io/no-provisioner"
  metadata {
    name = "nexus-storage-class"
  }
  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "kubernetes_persistent_volume" "nexus-pv" {
  count = var.create_nexus ? 1 : 0
  metadata {
    name = "nexus-pv"
  }
  spec {
    storage_class_name = "nexus-storage-class"
    access_modes       = ["ReadWriteOnce"]
    capacity = {
      storage = "40Gi"
    }
    persistent_volume_source {
      host_path {
        path = "/nexus"
      }
    }
    persistent_volume_reclaim_policy = "Retain"
  }
}

resource "kubernetes_persistent_volume_claim" "nexus-pvc" {
  count = var.create_nexus ? 1 : 0
  depends_on = [kubernetes_persistent_volume.nexus-pv, kubernetes_namespace.nexus-namespace]
  metadata {
    name      = "nexus-pvc"
    namespace = "nexus"
  }
  spec {
    storage_class_name = "nexus-storage-class"
    access_modes       = ["ReadWriteOnce"]
    volume_name        = kubernetes_persistent_volume.nexus-pv[count.index].metadata.0.name
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

module "helm-chart-nexus" {
  source = "git@bitbucket.org:securonixsnypr/helm-chart-nexus.git"
}

// create helm nexus
resource "helm_release" "nexus" {
  count     = var.create_nexus ? 1 : 0
  chart     = ".terraform/modules/cicd-infra.helm-chart-nexus/charts/nexus-repository-manager"
  name      = "nexus"
  namespace = "nexus"
  values = [<<EOF
    ingress:
      enabled: true
      annotations:
        kubernetes.io/ingress.class: nginx
        ingress.kubernetes.io/proxy-body-size: 50m
      hostPath: /
      hostRepo: nexus.securonix.net
    persistence:
      enabled: true
      existingClaim: nexus-pvc
    EOF
  ]
}
