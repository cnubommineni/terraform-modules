resource "aws_security_group" "rds_postgres_sg" {
  name        = "${var.environment_name}-${var.region}-rds_postgres_sg"
  description = "Used for RDS Mysql Instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = [var.vpn_cidr, local.vpc_cidr]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
module "rds_postgres" {
  source  = "terraform-aws-modules/rds/aws"
  version = "3.5.0"

  identifier = "${var.environment_name}-${var.region}-postgres"
  engine               = "postgres"
  engine_version       = var.postgres_engine_version
  family               = "postgres13" # DB parameter group
  major_engine_version = "13"         # DB option group
  instance_class       = "db.m5.large"

  allocated_storage     = 200
  storage_encrypted     = false

  name     = "sampledb"
  username = "root"
  password = var.rds_postgres_root_password
  port     = 5432

  multi_az               = true
  subnet_ids             = module.vpc.database_subnets
  vpc_security_group_ids = [aws_security_group.rds_postgres_sg.id]

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  deletion_protection     = true

  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "${var.environment_name}-${var.region}-postgres-monitor-role"
  monitoring_role_description           = "Description for monitoring role"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]
}
