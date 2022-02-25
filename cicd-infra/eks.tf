resource "aws_security_group" "node_security_group" {
  name_prefix = "node_security_group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      local.public_subnet_1,
      local.public_subnet_2,
      local.public_subnet_3
    ]
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = var.environment_name
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc.vpc_id

  node_groups_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    key_name               = var.nodes_pem_key_name
    create_launch_template = true
    pre_userdata           = <<USER_DATA
    echo "User data execution started..." &&
    mkdir /jenkins &&
    mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.jenkins-efs.id}.efs.${var.region}.amazonaws.com:/ /jenkins &&
    chmod 777 /jenkins &&
    mkdir /nexus &&
    mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.nexus-efs.id}.efs.${var.region}.amazonaws.com:/ /nexus &&
    chmod 777 /nexus &&
    mkdir /sonarqube &&
    mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.sonar-efs.id}.efs.${var.region}.amazonaws.com:/ /sonarqube &&
    chmod 777 /sonarqube
    USER_DATA
  }
  worker_additional_security_group_ids = [aws_security_group.node_security_group.id]
  node_groups = {
    devops_tools = {
      desired_capacity = 2
      max_capacity     = 4
      min_capacity     = 2

      instance_types = [
      "t2.large"]
      capacity_type = "ON_DEMAND"
      k8s_labels = {
        Environment = var.environment_name
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      additional_tags = {
        ExtraTag = "devops-tools"
      }
    }

    jenkins_agents = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1

      instance_types = [
      "t2.medium"]
      capacity_type = "ON_DEMAND"
      k8s_labels = {
        Environment = var.environment_name
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      additional_tags = {
        ExtraTag = "jenkins-agent"
      }
      taints = [
        {
          key    = "dedicated"
          value  = "jenkinsAgentsGroup"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }

  map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts
}
