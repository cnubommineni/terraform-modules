resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${var.environment_name}-${var.region}-redis-subnet-group"
  subnet_ids = module.vpc.elasticache_subnets
}

resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id           = "${var.environment_name}-${var.region}-redis"
  engine               = "redis"
  node_type            = "cache.t3.small"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis4.0"
  engine_version       = "4.0.10"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  //security_group_ids   = [aws_elasticache_security_group.redis_cache_sg.id]
}
