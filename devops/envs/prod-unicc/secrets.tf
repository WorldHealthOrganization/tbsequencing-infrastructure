resource "aws_secretsmanager_secret" "ncbi_entrez" {
  name = "${var.environment}/ncbi-entrez"
}

resource "aws_secretsmanager_secret" "django" {
  name = "${var.environment}/django"
}

resource "aws_secretsmanager_secret" "adfs" {
  name = "${var.environment}/adfs"
}
