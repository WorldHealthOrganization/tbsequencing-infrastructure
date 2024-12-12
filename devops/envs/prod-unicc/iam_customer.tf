# resource "aws_iam_user" "finddx-sacha" {
#   name = "finddx-sacha"
# }

# resource "aws_iam_user_policy_attachment" "finddx-sacha" {
#   user       = aws_iam_user.finddx-sacha.name
#   policy_arn = aws_iam_policy.finddx-sacha_cloudwatch-logs.arn
# }

# resource "aws_iam_user_policy_attachment" "finddx-sacha_stepfunctions-readonly" {
#   user       = aws_iam_user.finddx-sacha.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsReadOnlyAccess"
# }

# resource "aws_iam_user_policy_attachment" "finddx-sacha_glue_readonly_attach" {
#   user       = aws_iam_user.finddx-sacha.name
#   policy_arn = aws_iam_policy.finddx-sacha_glue_readonly_policy.arn
# }

# resource "aws_iam_user_policy_attachment" "finddx-sacha_session_manager_custom_attach" {
#   user       = aws_iam_user.finddx-sacha.name
#   policy_arn = aws_iam_policy.finddx-sacha_session_manager_custom_policy.arn
# }

# resource "aws_iam_user_policy_attachment" "finddx-sacha_ecs_debug_attach" {
#   user       = aws_iam_user.finddx-sacha.name
#   policy_arn = aws_iam_policy.finddx-sacha_ecs_debug_policy.arn
# }

# resource "aws_iam_user_policy_attachment" "finddx-sacha_stepfunctions-readonly_attach" {
#   user       = aws_iam_user.finddx-sacha.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsReadOnlyAccess"
# }

# resource "aws_iam_user_policy_attachment" "finddx-sacha_sqs-readonly_attach" {
#   user       = aws_iam_user.finddx-sacha.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess"
# }

# resource "aws_iam_user_policy_attachment" "finddx-sacha_readonly_attach" {
#   user       = aws_iam_user.finddx-sacha.name
#   policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
# }

# resource "aws_iam_user_policy_attachment" "finddx-sacha_ssm-start-session-readonly_attach" {
#   user       = aws_iam_user.finddx-sacha.name
#   policy_arn = "arn:aws:iam::343561796096:policy/unicc-ssm-start-session-policy"
# }

# resource "aws_iam_user_policy_attachment" "finddx-sacha_rds-performance-insights-readonly_attach" {
#   user       = aws_iam_user.finddx-sacha.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonRDSPerformanceInsightsReadOnly"
# }


resource "aws_iam_policy" "finddx-sacha_cloudwatch-logs" {
  name        = "CloudWatchLogsViewAccess"
  description = "Enable the view of Cloudwatch logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "cloudwatch:GetMetricData",
          "logs:ListAnomalies",
          "logs:ListTagsForResource",
          "logs:DescribeSubscriptionFilters",
          "logs:DescribeAccountPolicies",
          "logs:GetDataProtectionPolicy"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_policy" "finddx-sacha_glue_readonly_policy" {
  name        = "GlueReadOnlyCustom"
  description = "Custom read-only access policy for AWS Glue"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "glue:Get*",
          "glue:List*",
          "glue:Search*",
          "glue:BatchGet*",
          "glue:Describe*",
          "glue:View*"
        ],
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_policy" "finddx-sacha_session_manager_custom_policy" {
  name        = "SessionManagerCustomPolicy"
  description = "Custom policy for AWS Session Manager"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:StartSession"
        ],
        Resource = [
          "arn:aws:ec2:*:*:instance/*",
          "arn:aws:ssm:*:*:document/UNICC-SSM-SessionManagerRunShell"
        ],
        Condition = {
          BoolIfExists = {
            "ssm:SessionDocumentAccessCheck" : "true"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:DescribeSessions",
          "ssm:GetConnectionStatus",
          "ssm:DescribeInstanceProperties",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ssm:DescribeInstanceInformation"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:TerminateSession",
          "ssm:ResumeSession"
        ],
        Resource = [
          "arn:aws:ssm:*:*:session/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:GenerateDataKey"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_policy" "finddx-sacha_ecs_debug_policy" {
  name        = "ECSDebugPolicy"
  description = "Policy for debugging applications on ECS"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:DescribeClusters",
          "ecs:DescribeContainerInstances",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListClusters",
          "ecs:ListContainerInstances",
          "ecs:ListServices",
          "ecs:ListTaskDefinitions",
          "ecs:ListTasks",
          "logs:GetLogEvents",
          "logs:DescribeLogStreams",
          "ec2:DescribeInstances",
          "elasticloadbalancing:Describe*"
        ],
        Resource = "*"
      }
    ]
  })
}
