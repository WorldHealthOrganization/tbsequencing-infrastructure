data "aws_iam_policy_document" "oidc_policy" {
  for_each = local.repo_mappings
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.this.arn
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = each.value.repos
    }
  }
}

data "aws_iam_policy_document" "ec2_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "fargate_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "lambda_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "rds_access" {
  statement {
    actions = [
      "rds-db:connect"
    ]
    resources = ["arn:aws:rds-db:${local.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${module.db_default.db_instance_resource_id}/rdsiamuser"]
  }
}

data "aws_iam_policy_document" "fargate-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "fargate_execution" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]
    resources = [
      module.ecr.ecr_arns["backend"]
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "${resource.aws_cloudwatch_log_group.backend_fargate_task.arn}:*",
      "${resource.aws_cloudwatch_log_group.migration_fargate_task.arn}:*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      resource.aws_secretsmanager_secret.adfs.arn,
      resource.aws_secretsmanager_secret.django.arn,
    ]
  }
}

data "aws_iam_policy_document" "fargate_task" {
  # The task creates specific log groups for some activities
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "${resource.aws_cloudwatch_log_group.django-delegate.arn}:*",
      "${resource.aws_cloudwatch_log_group.django-admin.arn}:*",
      "${resource.aws_cloudwatch_log_group.django-server.arn}:*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      resource.aws_secretsmanager_secret.ncbi_entrez.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "ses:FromAddress"
      values = [
        var.no_reply_email
      ]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ses:GetSendStatistics",
      "ses:GetSendQuota"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions"
    ]
    resources = [
      module.s3.bucket_arn["backend-sequence-data"],
      module.s3.bucket_arn["backend-media"],
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "${module.s3.bucket_arn["backend-sequence-data"]}/*",
      "${module.s3.bucket_arn["backend-media"]}/*"
    ]
  }

}

data "aws_iam_policy_document" "step_function_executions" {
  statement {
    effect = "Allow"
    actions = [
      "states:ListExecutions",
      "states:ListMapRuns",
      "states:ListStateMachines",
      "states:StartExecution",
      "states:StartExecution",
      "states:StopExecution",
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "glue_executions" {
  statement {
    effect = "Allow"
    actions = [
      "glue:ListCrawlers",
      "glue:ListCrawls",
      "glue:ListJobs",
      "glue:ListSchemas",
      "glue:GetJob",
      "glue:GetJobBookmark",
      "glue:GetJobRun",
      "glue:GetCrawlers",
      "glue:GetCrawler",
      "glue:GetCrawlerMetrics",
      "glue:StartCrawler",
      "glue:StartJobRun",
      "glue:StopCrawler",
      "glue:ResetJobBookmark"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "frontend-static-s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${local.prefix}-static-files/*",
      "arn:aws:s3:::${local.prefix}-static-files"
    ]
  }
}

data "aws_iam_policy_document" "backend-static-s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${local.prefix}-django-static-files/*",
      "arn:aws:s3:::${local.prefix}-django-static-files"
    ]
  }
}

data "aws_iam_policy_document" "glue-scripts-s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${local.prefix}-glue-scripts/*",
      "arn:aws:s3:::${local.prefix}-glue-scripts"
    ]
  }
}

data "aws_iam_policy_document" "backend-read-ecs-logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:GetLogEvents"
    ]
    resources = [
      "arn:aws:logs:${local.aws_region}:${data.aws_caller_identity.current.id}:log-group:${aws_cloudwatch_log_group.migration_fargate_task.name}:log-stream:*",
    ]
  }
}

data "aws_iam_policy_document" "allow-distribution-invalidation" {
  statement {
    effect = "Allow"
    actions = [
      "cloudfront:GetInvalidation",
      "cloudfront:CreateInvalidation"
    ]
    resources = [
      "${module.cloudfront.distribution_arn}"
    ]
  }
}

data "aws_iam_policy_document" "get-tag-resources" {
  statement {
    effect = "Allow"
    actions = [
      "tag:GetResources",
    ]
    resources = [
      "*"
    ]
  }
}
