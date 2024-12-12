data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_2_latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ICC Golden AL2023 standard x86_64*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  # owners = ["amazon"]
}

data "aws_acm_certificate" "tbsequencing" {
  domain = "tbsequencing.who.int"
}

data "aws_db_snapshot" "prod" {
  db_instance_identifier = "fdxmaindbforproddefault"
}

data "aws_iam_policy" "bastion-ssm" {
  name = "unicc-ssm-s3-data-policy"
}

data "aws_ssm_parameter" "ms_teams_tenant_id" {
  name = "/${var.environment}/ms_teams_tenant_id"
}

data "aws_ssm_parameter" "ms_teams_group_id" {
  name = "/${var.environment}/ms_teams_group_id"
}

data "aws_ssm_parameter" "ms_teams_channel_id" {
  name = "/${var.environment}/ms_teams_channel_id"
}
