variable "region" {
  default = "us-west-2"
}

variable "environment_name" {
  default = "dev02"
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = ["073885930324", "853268358782"]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::175513997821:role/GroupAccess-Admin"
      username = "GroupAccess-Admin"
      groups   = ["system:masters"]
    },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::175513997821:user/smahale@securonix.com"
      username = "smahale@securonix.com"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::175513997821:user/bpantala@securonix.com"
      username = "bpantala@securonix.com"
      groups   = ["system:masters"]
    },
  ]
}

variable "ssl_cert_arn" {
  default = "arn:aws:acm:us-east-1:587219698707:certificate/30bb7777-1689-4395-9f65-cfba136fdba3"
}

variable "jump_pem_key_name" {
  default = "dummy-name.pem"
}

variable "nodes_pem_key_name" {
  default = "dummy-name.pem"
}

variable "aws_profile_to_use" {
  default = "dev"
}

variable "create_ingress_nginx" {
  default = false
}

variable "create_prometheus_operator" {
  default = false
}

variable "bastion_image_id" {
  default = "ami-0c2b8ca1dad447f8a"
}

variable "vpc_cidr_first_octet"{
  default = "172"
}

variable "vpc_cidr_second_octet"{
  default = "160"
}

variable "vpn_cidr"{
  default = "172.14.0.0/16"
}

variable "rds_mysql_root_password"{
  default = "Securonix10#"
}

variable "rds_postgres_root_password"{
  default = "Securonix10#"
}

variable "mysql_engine_version"{
  default = "5.7.33"
}

variable "postgres_engine_version"{
  default = "13.3"
}

variable "auto_accept"{
  default = "true"
}

variable "peer_vpc"{
  default = "vpc-0fd9b10ae48dbb8e1"
}

variable "peer_account"{
  default = "073885930324"
}

variable "peer_region"{
  default = "us-east-2"
}

variable "use_cross_account"{
  default = "false"
}