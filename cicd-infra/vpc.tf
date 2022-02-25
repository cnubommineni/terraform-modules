
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.47"

  name = "${var.environment_name}-eks-vpc"
  cidr = local.vpc_cidr
  azs  = data.aws_availability_zones.available.names
  private_subnets = [
    local.private_subnet_1,
    local.private_subnet_2,
  local.private_subnet_3]
  public_subnets = [
    local.public_subnet_1,
    local.public_subnet_2,
  local.public_subnet_3]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}