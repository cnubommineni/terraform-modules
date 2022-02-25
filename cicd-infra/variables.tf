variable "region" {
  default = "us-east-1"
}

variable "environment_name" {
  default = "prod"
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
    "587219698707",
    "151162882430",
  ]
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
      rolearn  = "arn:aws:iam::587219698707:role/GroupAccess-Admin"
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
      userarn  = "arn:aws:iam::587219698707:user/smahale@securonix.com"
      username = "smahale@securonix.com"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::587219698707:user/bpantala@securonix.com"
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

variable "create_jenkins" {
  default = false
}

variable "create_sonar" {
  default = false
}

variable "create_nexus" {
  default = false
}

variable "bastion_image_id" {
  default = "ami-0c2b8ca1dad447f8a"
}
