locals {
  vpc_cidr = "${var.vpc_cidr_first_octet}.${var.vpc_cidr_second_octet}.0.0/16"
}
locals {
  public_subnet_1 = "${var.vpc_cidr_first_octet}.${var.vpc_cidr_second_octet}.0.0/24"
}

locals {
  eks_private_subnet_1 = "${var.vpc_cidr_first_octet}.${var.vpc_cidr_second_octet}.1.0/24"
  eks_private_subnet_2 = "${var.vpc_cidr_first_octet}.${var.vpc_cidr_second_octet}.2.0/24"
  eks_private_subnet_3 = "${var.vpc_cidr_first_octet}.${var.vpc_cidr_second_octet}.3.0/24"
  eks_private_subnet_4 = "${var.vpc_cidr_first_octet}.${var.vpc_cidr_second_octet}.4.0/24"
  eks_private_subnet_5 = "${var.vpc_cidr_first_octet}.${var.vpc_cidr_second_octet}.5.0/24"
  eks_private_subnet_6 = "${var.vpc_cidr_first_octet}.${var.vpc_cidr_second_octet}.6.0/24"
  rds_private_subnet_1 = "${var.vpc_cidr_first_octet}.${var.vpc_cidr_second_octet}.7.0/24"
  rds_private_subnet_2 = "${var.vpc_cidr_first_octet}.${var.vpc_cidr_second_octet}.8.0/24"
  rds_private_subnet_3 = "${var.vpc_cidr_first_octet}.${var.vpc_cidr_second_octet}.9.0/24"
  redis_private_subnet_1 = "${var.vpc_cidr_first_octet}.${var.vpc_cidr_second_octet}.10.0/24"
}

locals {
  cluster_name = "${var.environment_name}-${var.region}"
}
