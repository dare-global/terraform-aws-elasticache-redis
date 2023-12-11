provider "aws" {
  region = "eu-west-2"
}

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.28.0"
    }
  }
}

#####
# VPC and subnets
#####
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

#####
# Elasticache Redis
#####
module "redis" {
  source = "../../"

  name_prefix        = "redis-basic"
  num_cache_clusters = 2

  engine_version           = "7.0"
  snapshot_retention_limit = 7

  automatic_failover_enabled = true
  multi_az_enabled           = true

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = "1234567890asdfghjkl"

  apply_immediately = true
  family            = "redis7"

  description = "Elasticache redis."

  subnet_ids = data.aws_subnets.all.ids
  vpc_id     = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  parameter = [
    {
      name  = "maxmemory-policy"
      value = "allkeys-lru"
    },
    {
      name  = "notify-keyspace-events"
      value = "KEA"
    }
  ]

  tags = {
    Project = "Test"
  }
}
