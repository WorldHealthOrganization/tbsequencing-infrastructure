resource "aws_ssm_parameter" "db_host" {
  name  = "/${var.environment}/db_host"
  type  = "String"
  value = module.db_default.db_instance_address
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/${var.environment}/db_name"
  type  = "String"
  value = module.db_default.db_instance_name
}

resource "aws_ssm_parameter" "db_port" {
  name  = "/${var.environment}/db_port"
  type  = "String"
  value = module.db_default.db_instance_port
}

resource "aws_ssm_parameter" "rds_credentials_secret_arn" {
  name  = "/${var.environment}/rds_credentials_secret_arn"
  type  = "String"
  value = module.db_default.db_managed_secret_credentials_arn
}

resource "aws_ssm_parameter" "rds_credentials_kms_key" {
  name  = "/${var.environment}/rds_credentials_kms_key"
  type  = "String"
  value = module.db_default.db_managed_secret_credentials_encryption_key
}

resource "aws_ssm_parameter" "db_instance_resource_id" {
  name  = "/${var.environment}/db_instance_resource_id"
  type  = "String"
  value = module.db_default.db_instance_resource_id
}

resource "aws_ssm_parameter" "sequence_data_bucket_name" {
  name  = "/${var.environment}/sequence_data_bucket_name"
  type  = "SecureString"
  value = module.s3.bucket_id["backend-sequence-data"]
}

resource "aws_ssm_parameter" "static_files_bucket_name" {
  name  = "/${var.environment}/static_files_bucket_name"
  type  = "SecureString"
  value = module.cloudfront.static-bucket
}
