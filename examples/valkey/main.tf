provider "aws" {
  region = "eu-west-2"
}

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83.0"
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
# Elasticache Valkey
#####
module "valkey" {
  source = "../../"

  engine         = "valkey"
  engine_version = "8.0"

  name_prefix        = "redis-basic"
  num_cache_clusters = 2

  snapshot_retention_limit = 7

  automatic_failover_enabled = true
  multi_az_enabled           = true

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  apply_immediately = true
  family            = "valkey8"

  description = "Elasticache Valkey."

  subnet_ids = data.aws_subnets.all.ids
  vpc_id     = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Project = "Test"
  }
}
