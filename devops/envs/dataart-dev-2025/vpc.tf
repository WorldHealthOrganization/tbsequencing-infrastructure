# vpc
locals {
  availability_zones   = ["${local.aws_region}a", "${local.aws_region}b"]
  cidr_block           = "10.19.0.0/16"
  public_subnets       = ["10.19.0.0/24", "10.19.1.0/24"]
  public_subnet_names  = ["${local.prefix}-public-${local.aws_region}a", "${local.prefix}-public-${local.aws_region}b"]
  private_subnets      = ["10.19.16.0/24", "10.19.17.0/24", "10.19.18.0/24"]
  private_subnet_names = ["${local.prefix}-private-${local.aws_region}a", "${local.prefix}-private-${local.aws_region}b", "${local.prefix}-private-security-${local.aws_region}a"]
}

module "vpc" {
  source               = "git::https://github.com/finddx/seq-treat-tbkb-terraform-modules.git//vpc?ref=vpc-v1.1"
  name                 = local.prefix
  enable_dns_hostnames = true
  enable_dns_support   = true

  azs  = local.availability_zones
  cidr = local.cidr_block

  private_subnets      = var.low_cost_implementation ? [] : local.private_subnets
  private_subnet_names = var.low_cost_implementation ? [] : local.private_subnet_names

  public_subnets      = local.public_subnets
  public_subnet_names = local.public_subnet_names

  manage_default_security_group = true

  enable_nat_gateway     = !var.low_cost_implementation
  one_nat_gateway_per_az = !var.low_cost_implementation

  private_subnet_tags = {
    Label = "${var.project_name}-${var.environment}-private-subnets"
  }

  public_subnet_tags = {
    Label = "${var.project_name}-${var.environment}-public-subnets"
  }
}

#/!\ Gateway endpoints do not support security groups /!\
module "vpc_endpoints" {
  source = "git::https://github.com/finddx/seq-treat-tbkb-terraform-modules.git//vpc/modules/vpc-endpoints?ref=vpc-v1.1"
  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = var.low_cost_implementation ? module.vpc.public_route_table_ids : module.vpc.private_route_table_ids
      tags            = { Name = "s3-gateway" }
    }
  }
}

module "secrets_interface_endpoints" {
  count              = var.low_cost_implementation ? 1 : 0
  source             = "git::https://github.com/finddx/seq-treat-tbkb-terraform-modules.git//vpc/modules/vpc-endpoints?ref=vpc-v1.1"
  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.sg.security_group_id["vpc-endpoints"]]

  endpoints = {
    secrets = {
      service_name        = "com.amazonaws.${local.aws_region}.secretsmanager"
      service_type        = "Interface"
      subnet_ids          = [module.vpc.public_subnets[0]]
      tags                = { Name = "secrets-interface" }
      private_dns_enabled = true
    }
  }
}
