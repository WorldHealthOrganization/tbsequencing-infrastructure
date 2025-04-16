# EC2 instance IAM role


resource "aws_iam_openid_connect_provider" "this" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
  tags = merge({ "Name" = "github-actions-integration" }, local.tags)
}

locals {
  repo_mappings = {
    "my-github-actions-frontend" = {
      repos = [
        "repo:WorldHealthOrganization/tbsequencing-frontend:environment:${var.environment}"
      ]
    }
    "my-github-actions-backend" = {
      repos = [
        "repo:WorldHealthOrganization/tbsequencing-backend:environment:${var.environment}"
      ]
    }
    "my-github-actions-push-glue" = {
      repos = [
        "repo:WorldHealthOrganization/tbsequencing-bioinfoanalysis:environment:${var.environment}",
        "repo:WorldHealthOrganization/tbsequencing-antimalware:environment:${var.environment}",
        "repo:WorldHealthOrganization/tbsequencing-ncbi-sync:environment:${var.environment}",
        "repo:WorldHealthOrganization/tbsequencing-backend:environment:${var.environment}"
      ]
    }
  }

  policies = [
    {
      name        = "rds_access"
      description = ""
      policy      = data.aws_iam_policy_document.rds_access.json
    },
    {
      name        = "fargate-execution-policy"
      description = ""
      policy      = data.aws_iam_policy_document.fargate_execution.json
    },
    {
      name        = "fargate-task-policy"
      description = ""
      policy      = data.aws_iam_policy_document.fargate_task.json
    },
    {
      name        = "step-function-executions-policy"
      description = ""
      policy      = data.aws_iam_policy_document.step_function_executions.json
    },
    {
      name        = "glue-executions-policy"
      description = ""
      policy      = data.aws_iam_policy_document.glue_executions.json
    },
    {
      name        = "batch-jobs-policy"
      description = ""
      policy      = data.aws_iam_policy_document.batch_jobs.json
    },
    {
      name        = "s3-restore-policy"
      description = ""
      policy      = data.aws_iam_policy_document.s3_restore.json
    },

    {
      name        = "backend-static-s3"
      description = ""
      policy      = data.aws_iam_policy_document.backend-static-s3.json
    },
    {
      name        = "frontend-static-s3"
      description = ""
      policy      = data.aws_iam_policy_document.frontend-static-s3.json
    },
    {
      name        = "glue-scripts-s3"
      description = ""
      policy      = data.aws_iam_policy_document.glue-scripts-s3.json
    },
    {
      name        = "read-ecs-logs"
      description = ""
      policy      = data.aws_iam_policy_document.backend-read-ecs-logs.json
    },
    {
      name        = "allow-distribution-invalidation"
      description = ""
      policy      = data.aws_iam_policy_document.allow-distribution-invalidation.json
    },
    {
      name        = "get-tag-resources"
      description = ""
      policy      = data.aws_iam_policy_document.get-tag-resources.json
    },
  ]

  policy_mapping = {
    ecs_task_execution_role = {
      role   = module.roles.role_name["fargate-execution-role"]
      policy = module.policies.policy_arn["fargate-execution-policy"]
    }
    fargate_task = {
      role   = module.roles.role_name["fargate"]
      policy = module.policies.policy_arn["fargate-task-policy"]
    }
    rds_access = {
      role   = module.roles.role_name["fargate"]
      policy = module.policies.policy_arn["rds_access"]
    }
    bastion_role_attachment = {
      role   = module.roles.role_name["ec2"]
      policy = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
    bastion_step_function = {
      role   = module.roles.role_name["ec2"]
      policy = module.policies.policy_arn["step-function-executions-policy"]
    }
    bastion_glue = {
      role   = module.roles.role_name["ec2"]
      policy = module.policies.policy_arn["glue-executions-policy"]
    }
    bastion_batch = {
      role   = module.roles.role_name["ec2"]
      policy = module.policies.policy_arn["batch-jobs-policy"]
    }
    bastion_s3_restore = {
      role   = module.roles.role_name["ec2"]
      policy = module.policies.policy_arn["s3-restore-policy"]
    }
    bastion_role_rds_access = {
      role   = module.roles.role_name["ec2"]
      policy = module.policies.policy_arn["rds_access"]
    }
    bastion_ssm = {
      role   = module.roles.role_name["ec2"]
      policy = data.aws_iam_policy.bastion-ssm.arn
    }
    backend-static = {
      role   = module.roles.role_name["my-github-actions-backend"]
      policy = module.policies.policy_arn["backend-static-s3"]
    }
    backend-logs = {
      role   = module.roles.role_name["my-github-actions-backend"]
      policy = module.policies.policy_arn["read-ecs-logs"]
    }
    backend-invalidate = {
      role   = module.roles.role_name["my-github-actions-backend"]
      policy = module.policies.policy_arn["allow-distribution-invalidation"]
    }
    backend-tag = {
      role   = module.roles.role_name["my-github-actions-backend"]
      policy = module.policies.policy_arn["get-tag-resources"]
    }
    backend-ecs = {
      role   = module.roles.role_name["my-github-actions-backend"]
      policy = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
    }
    backend-ecr = {
      role   = module.roles.role_name["my-github-actions-backend"]
      policy = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
    }
    frontend-static = {
      role   = module.roles.role_name["my-github-actions-frontend"]
      policy = module.policies.policy_arn["frontend-static-s3"]
    }
    frontend-invalidate = {
      role   = module.roles.role_name["my-github-actions-frontend"]
      policy = module.policies.policy_arn["allow-distribution-invalidation"]
    }
    frontend-tag = {
      role   = module.roles.role_name["my-github-actions-frontend"]
      policy = module.policies.policy_arn["get-tag-resources"]
    }
    glue-s3 = {
      role   = module.roles.role_name["my-github-actions-push-glue"]
      policy = module.policies.policy_arn["glue-scripts-s3"]
    }
    glue-ecr = {
      role   = module.roles.role_name["my-github-actions-push-glue"]
      policy = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
    }
  }

  roles = [
    {
      name                    = "ec2"
      instance_profile_enable = true
      instance_profile_name   = "${local.prefix}-amazon-linux-2"
      custom_trust_policy     = data.aws_iam_policy_document.ec2_role.json
    },
    {
      name                    = "fargate-execution-role"
      instance_profile_enable = null
      custom_trust_policy     = data.aws_iam_policy_document.fargate-role-policy.json
    },
    {
      name                    = "fargate"
      instance_profile_enable = null
      custom_trust_policy     = data.aws_iam_policy_document.fargate-role-policy.json
    },
    {
      name                    = "lambda"
      instance_profile_enable = null
      custom_trust_policy     = data.aws_iam_policy_document.lambda_role.json
    },
    {
      name                    = "my-github-actions-frontend"
      instance_profile_enable = null
      custom_trust_policy     = data.aws_iam_policy_document.oidc_policy["my-github-actions-frontend"].json
    },
    {
      name                    = "my-github-actions-backend"
      instance_profile_enable = null
      custom_trust_policy     = data.aws_iam_policy_document.oidc_policy["my-github-actions-backend"].json
    },
    {
      name                    = "my-github-actions-push-glue"
      instance_profile_enable = null
      custom_trust_policy     = data.aws_iam_policy_document.oidc_policy["my-github-actions-push-glue"].json
    },
  ]
}

module "policies" {
  source       = "git::git@bitbucket.org:awsopda/who-seq-treat-tbkb-terraform-modules.git//iam_policy?ref=iam_policy-v1.0"
  aws_region   = local.aws_region
  environment  = var.environment
  project_name = var.project_name
  module_name  = var.module_name
  policies     = local.policies
}

module "policy_mapping" {
  source     = "git::git@bitbucket.org:awsopda/who-seq-treat-tbkb-terraform-modules.git//iam_policy_mapping?ref=iam_policy_mapping-v1.0"
  aws_region = local.aws_region
  roles      = local.policy_mapping
}

module "roles" {
  source       = "git::git@bitbucket.org:awsopda/who-seq-treat-tbkb-terraform-modules.git//iam_role?ref=iam_role-v1.0"
  aws_region   = local.aws_region
  environment  = var.environment
  project_name = var.project_name
  module_name  = var.module_name
  roles        = local.roles
}

resource "aws_iam_service_linked_role" "chatbot" {
  aws_service_name = "management.chatbot.amazonaws.com"
}
