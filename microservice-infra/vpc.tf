module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.47"

  name = "${var.environment_name}-${var.region}"
  cidr = local.vpc_cidr
  azs  = data.aws_availability_zones.azs.names
  private_subnets = [
    local.eks_private_subnet_1,
    local.eks_private_subnet_2,
    local.eks_private_subnet_3,
    local.eks_private_subnet_4,
    local.eks_private_subnet_5,
    local.eks_private_subnet_6]
  database_subnets = [
    local.rds_private_subnet_1,
    local.rds_private_subnet_2,
    local.rds_private_subnet_3]
  elasticache_subnets = [local.redis_private_subnet_1]
  public_subnets = [local.public_subnet_1]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

locals {
  all_route_tables = distinct(concat(
    [module.vpc.default_route_table_id],
    [module.vpc.vpc_main_route_table_id],
    module.vpc.public_route_table_ids,
    module.vpc.private_route_table_ids,
    module.vpc.database_route_table_ids,
    module.vpc.elasticache_route_table_ids))
}


resource "aws_vpc_peering_connection" "ms_peering" {
  vpc_id        = module.vpc.vpc_id
  peer_vpc_id   = var.peer_vpc
  //auto_accept   = var.auto_accept
  peer_owner_id = var.peer_account
  //peer_region   = var.peer_region
  peer_region = var.peer_region
  tags = {
    Name        = "${var.region}-${var.environment_name}-vpc-peering"
    Environment = var.environment_name
  }
}

/*
resource "aws_route" "peering_table" {
  count                     = length(local.all_route_tables)
  route_table_id            = local.all_route_tables[count.index]
  destination_cidr_block    = var.vpn_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.ms_peering.id
}

output "all_tables" {
  value = local.all_route_tables
}
*/
