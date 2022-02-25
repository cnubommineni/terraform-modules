/*

resource "aws_iam_user" "smahale" {
  name = "smahale@securonix.com"
}

resource "aws_iam_user" "bpantala" {
  name = "bpantala@securonix.com"
}

module "iam_iam-assumable-roles" {
  source                  = "terraform-aws-modules/iam/aws//modules/iam-assumable-roles"
  version                 = "4.2.0"
  create_admin_role       = true
  admin_role_requires_mfa = false
  admin_role_name         = "GroupAccess-Admin"
  trusted_role_arns       = [aws_iam_user.smahale.arn]
}*/
