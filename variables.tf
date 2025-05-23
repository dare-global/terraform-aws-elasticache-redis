variable "name_prefix" {
  type        = string
  description = "The replication group identifier. This parameter is stored as a lowercase string."
}

variable "engine" {
  type        = string
  description = "Name of the cache engine to be used for the clusters in this replication group. Valid values are redis or valkey. Default is redis."
  default     = "redis"
}

variable "num_cache_clusters" {
  type        = number
  default     = 1
  description = "The number of cache clusters (primary and replicas) this replication group will have. If Multi-AZ is enabled, the value of this parameter must be at least 2. Updates will occur before other modifications. Conflicts with num_node_groups."
}

variable "cluster_mode_enabled" {
  type        = bool
  description = "Enable creation of a native redis cluster."
  default     = false
}

variable "node_type" {
  type        = string
  description = "The compute and memory capacity of the nodes in the node group."
  default     = "cache.t4g.small"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of VPC Subnet IDs for the cache subnet group."
}

variable "vpc_id" {
  type        = string
  description = "VPC Id to associate with Redis ElastiCache."
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "List of Ingress CIDR blocks."
  default     = []
}

variable "ingress_self" {
  type        = bool
  description = "Specify whether the security group itself will be added as a source to the ingress rule."
  default     = false
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of Security Groups."
  default     = []
}

variable "engine_version" {
  default     = "7.0"
  type        = string
  description = "The version number of the cache engine to be used for the cache clusters in this replication group."
}

variable "port" {
  default     = 6379
  type        = number
  description = "The port number on which each of the cache nodes will accept connections."
}

variable "maintenance_window" {
  default     = null
  type        = string
  description = "Specifies the weekly time range for when maintenance on the cache cluster is performed."
}

variable "snapshot_window" {
  default     = null
  type        = string
  description = "The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster."
}

variable "snapshot_retention_limit" {
  default     = 30
  type        = number
  description = "The number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them."
}

variable "auto_minor_version_upgrade" {
  default = true
  type    = bool
}

variable "automatic_failover_enabled" {
  default     = null
  type        = bool
  description = "Specifies whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails. If enabled, number_cache_clusters must be greater than 1. Must be enabled for Redis (cluster mode enabled) replication groups."
}

variable "at_rest_encryption_enabled" {
  default     = null
  type        = bool
  description = "Whether to enable encryption at rest. When engine is redis, default is false. When engine is valkey, default is true."
}

variable "transit_encryption_enabled" {
  default     = true
  type        = bool
  description = "Whether to enable encryption in transit."
}

variable "transit_encryption_mode" {
  description = "A setting that enables clients to migrate to in-transit encryption with no downtime. Valid values are preferred and required"
  type        = string
  default     = null
}

variable "apply_immediately" {
  default     = false
  type        = bool
  description = "Specifies whether any modifications are applied immediately, or during the next maintenance window."
}

variable "family" {
  default     = "redis7"
  type        = string
  description = "The family of the ElastiCache parameter group."
}

variable "description" {
  default     = "Managed by Terraform"
  type        = string
  description = "The description of the all resources."
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
}

variable "auth_token" {
  type        = string
  description = "The password used to access a password protected server. Can be specified only if `transit_encryption_enabled = true`."
  default     = null
}

variable "auth_token_update_strategy" {
  type        = string
  description = "Strategy to use when updating the auth_token. Valid values are SET, ROTATE, and DELETE. Defaults to ROTATE"
  default     = "ROTATE"
}

variable "kms_key_id" {
  type        = string
  description = "The ARN of the key that you wish to use if encrypting at rest. If not supplied, uses service managed encryption. Can be specified only if `at_rest_encryption_enabled = true`"
  default     = null
}

variable "parameter" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "A list of Redis parameters to apply. Note that parameters may differ from one Redis family to another"
}

variable "notification_topic_arn" {
  type        = string
  default     = null
  description = "An Amazon Resource Name (ARN) of an SNS topic to send ElastiCache notifications to. Example: `arn:aws:sns:us-east-1:012345678999:my_sns_topic`"
}

variable "replicas_per_node_group" {
  type        = number
  default     = 0
  description = "Specify the number of replica nodes in each node group. Valid values are 0 to 5. Changing this number will trigger an online resizing operation before other settings modifications."

  validation {
    condition     = var.replicas_per_node_group <= 5
    error_message = "The replicas_per_node_group value must be between 0 and 5."
  }
}

variable "num_node_groups" {
  type        = number
  default     = 0
  description = "Specify the number of node groups (shards) for this Redis replication group. Changing this number will trigger an online resizing operation before other settings modifications."
}

variable "preferred_cache_cluster_azs" {
  type        = list(string)
  description = "A list of EC2 availability zones in which the replication group's cache clusters will be created. The order of the availability zones in the list is not important."
  default     = null
}

variable "multi_az_enabled" {
  type        = bool
  description = "Specifies whether to enable Multi-AZ Support for the replication group. If true, `automatic_failover_enabled` must also be enabled. Defaults to false."
  default     = false
}

variable "final_snapshot_identifier" {
  type        = string
  description = "The name of your final node group (shard) snapshot. ElastiCache creates the snapshot from the primary node in the cluster. If omitted, no final snapshot will be made."
  default     = null
}

variable "global_replication_group_id" {
  description = "The ID of the global replication group to which this replication group should belong."
  type        = string
  default     = null
}

variable "log_delivery_configuration" {
  description = "(Redis OSS or Valkey) Specifies the destination and format of Redis OSS/Valkey SLOWLOG or Redis OSS/Valkey Engine Log"
  type        = any
  default     = []
}

variable "allowed_security_groups" {
  type        = list(string)
  description = "List of existing security groups that will be allowed ingress via the elaticache security group rules"
  default     = []
}

variable "data_tiering_enabled" {
  type        = bool
  default     = false
  description = "Enables data tiering. Data tiering is only supported for replication groups using the r6gd node type. This parameter must be set to true when using r6gd nodes."
}

variable "user_group_ids" {
  type        = list(string)
  default     = null
  description = "User Group ID to associate with the replication group"
}

variable "parameter_group_name" {
  type        = string
  default     = null
  description = "Parameter Group name. If not provided, it will use the module name"
}

variable "cluster_mode" {
  description = "Specifies whether cluster mode is enabled or disabled. Valid values are enabled or disabled or compatible"
  type        = string
  default     = null
}

variable "ip_discovery" {
  description = "The IP version to advertise in the discovery protocol. Valid values are `ipv4` or `ipv6`"
  type        = string
  default     = null
}

variable "network_type" {
  description = "The IP versions for cache cluster connections. Valid values are `ipv4`, `ipv6` or `dual_stack`"
  type        = string
  default     = null
}
