data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_2_latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
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

  owners = ["amazon"]
}

data "aws_secretsmanager_secret" "ms_teams" {
  name = "ms-teams"
}

data "aws_secretsmanager_secret_version" "ms_teams_current" {
  secret_id = data.aws_secretsmanager_secret.ms_teams.id
}

data "aws_acm_certificate" "tbsequencing" {
  domain = "tbkb-test-env.finddx.org"
}
