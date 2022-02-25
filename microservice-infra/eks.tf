resource "aws_security_group" "node_security_group" {
  name_prefix = "node_security_group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.eks_private_subnet_1,
      local.eks_private_subnet_2,
      local.eks_private_subnet_3,
      local.eks_private_subnet_4,
      local.eks_private_subnet_5,
      local.eks_private_subnet_6
    ]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version = "18.2.3"
  cluster_name    = local.cluster_name
  cluster_version = "1.21"
  subnet_ids         = module.vpc.private_subnets
  cluster_enabled_log_types = [ "audit", "api", "authenticator" ]
  cluster_endpoint_private_access = false
  cluster_endpoint_public_access  = true
  tags = {
    Environment = var.environment_name
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc.vpc_id
  cluster_addons = {
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }
# EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 200
    key_name     = var.nodes_pem_key_name
    instance_types         = ["t3.xlarge"]
    vpc_security_group_ids = [aws_security_group.node_security_group.id]
  }
  eks_managed_node_groups = {
    microservice_ng1 = {
      min_size     = 1
      max_size     = 10
      desired_size = 1
      ami_type     = "AL2_x86_64"
      instance_types = ["t3.xlarge"]
      capacity_type  = "ON_DEMAND"
     # iam_role_name = aws_iam_role.ms_node_group_iam_role.name
      create_launch_template = true
      labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      tags = {
        ExtraTag = "${var.environment_name}-${var.region}"
      }
    }
  }
}
