resource "aws_elasticache_replication_group" "redis" {
  engine = var.global_replication_group_id == null ? var.engine : null

  cluster_mode = var.cluster_mode

  ip_discovery = var.ip_discovery
  network_type = var.network_type

  parameter_group_name = var.global_replication_group_id == null ? aws_elasticache_parameter_group.redis.name : null
  subnet_group_name    = aws_elasticache_subnet_group.redis.name

  security_group_ids = concat(var.security_group_ids, [aws_security_group.redis.id])

  preferred_cache_cluster_azs = var.preferred_cache_cluster_azs
  replication_group_id        = var.global_replication_group_id == null ? (var.engine == "redis" ? "${var.name_prefix}-redis" : "${var.name_prefix}-valkey") : "${var.name_prefix}-redis-replica"

  node_type = var.global_replication_group_id == null ? var.node_type : null

  engine_version = var.global_replication_group_id == null ? var.engine_version : null
  port           = var.port

  maintenance_window         = var.maintenance_window
  snapshot_window            = var.snapshot_window
  snapshot_retention_limit   = var.snapshot_retention_limit
  final_snapshot_identifier  = var.final_snapshot_identifier
  automatic_failover_enabled = var.multi_az_enabled || var.cluster_mode_enabled ? true : var.automatic_failover_enabled
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  multi_az_enabled           = var.multi_az_enabled

  at_rest_encryption_enabled = var.global_replication_group_id == null ? var.at_rest_encryption_enabled : null
  transit_encryption_enabled = var.global_replication_group_id == null ? var.transit_encryption_enabled : null
  transit_encryption_mode    = var.global_replication_group_id == null ? var.transit_encryption_mode : null

  auth_token                 = var.auth_token
  auth_token_update_strategy = var.auth_token_update_strategy
  kms_key_id                 = var.at_rest_encryption_enabled ? var.kms_key_id : null

  global_replication_group_id = var.global_replication_group_id

  apply_immediately = var.apply_immediately

  description = var.description

  data_tiering_enabled = var.data_tiering_enabled

  notification_topic_arn = var.notification_topic_arn

  replicas_per_node_group = var.cluster_mode_enabled ? var.replicas_per_node_group : null
  num_node_groups         = var.cluster_mode_enabled ? var.num_node_groups : null
  num_cache_clusters      = var.cluster_mode_enabled ? null : var.num_cache_clusters
  user_group_ids          = var.user_group_ids

  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_configuration

    content {
      destination      = log_delivery_configuration.value.destination
      destination_type = log_delivery_configuration.value.destination_type
      log_format       = log_delivery_configuration.value.log_format
      log_type         = log_delivery_configuration.value.log_type
    }
  }

  tags = merge(
    {
      "Name" = var.engine == "redis" ? "${var.name_prefix}-redis" : "${var.name_prefix}-valkey"
    },
    var.tags,
  )
}

resource "random_id" "redis_pg" {
  keepers = {
    family      = var.family
    description = var.description
  }

  byte_length = 2
}

resource "aws_elasticache_parameter_group" "redis" {
  name = var.parameter_group_name == null ? (var.engine == "redis" ? "${var.name_prefix}-redis-${random_id.redis_pg.hex}" : "${var.name_prefix}-valkey-${random_id.redis_pg.hex}") : var.parameter_group_name

  family      = var.family
  description = var.description

  dynamic "parameter" {
    for_each = var.num_node_groups > 0 ? concat([{ name = "cluster-enabled", value = "yes" }], var.parameter) : var.parameter
    content {
      name  = parameter.value.name
      value = tostring(parameter.value.value)
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      description,
    ]
  }

  tags = var.tags
}

resource "aws_elasticache_subnet_group" "redis" {
  name        = var.global_replication_group_id == null ? (var.engine == "redis" ? "${var.name_prefix}-redis-sg" : "${var.name_prefix}-valkey-sg") : "${var.name_prefix}-redis-sg-replica"
  subnet_ids  = var.subnet_ids
  description = var.description

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "redis" {
  name_prefix = var.engine == "redis" ? "${var.name_prefix}-redis-" : "${var.name_prefix}-valkey-"

  description = "Elasticache Security Group ${var.name_prefix}"

  vpc_id = var.vpc_id

  tags = merge(
    {
      "Name" = var.engine == "redis" ? "${var.name_prefix}-redis" : "${var.name_prefix}-valkey"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "redis_ingress_self" {
  count = var.ingress_self ? 1 : 0

  description = "Self reference ingress."

  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.redis.id
}

resource "aws_security_group_rule" "redis_ingress_cidr_blocks" {
  count = length(var.ingress_cidr_blocks) != 0 ? 1 : 0

  description = "Allow Ingress CIDRs."

  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.ingress_cidr_blocks
  security_group_id = aws_security_group.redis.id
}

resource "aws_security_group_rule" "redis_egress" {
  description = "Allow all egress."

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.redis.id
}

resource "aws_security_group_rule" "other_sg_ingress" {
  count = length(var.allowed_security_groups)

  description = "Allow additional Ingress SGs."

  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = aws_security_group.redis.id
}
