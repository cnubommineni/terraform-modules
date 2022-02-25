resource "aws_security_group" "rds_mysql_sg" {
  name        = "rds_mysql_sg"
  description = "Used for RDS Mysql Instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = [var.vpn_cidr, local.vpc_cidr]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "rds_mysql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "3.5.0"

  identifier = "${var.environment_name}-${var.region}-mysql"

  engine            = "mysql"
  engine_version    = var.mysql_engine_version
  instance_class    = "db.m5.large"
  allocated_storage = 400

  name     = "snyprauth"
  username = "root"
  password = var.rds_mysql_root_password
  port     = "3306"
  multi_az               = true
  vpc_security_group_ids = [aws_security_group.rds_mysql_sg.id]
  create_monitoring_role = false
  tags = {
    Owner       = "user"
    Environment = "${var.environment_name}"
  }

  # DB subnet group
  subnet_ids = module.vpc.database_subnets
  family = "mysql5.7"
  major_engine_version = "5.7"
  # Database Deletion Protection
  deletion_protection = true
  parameters = [
    {
      name = "character_set_client"
      value = "utf8mb4"
    },
    {
      name = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}
