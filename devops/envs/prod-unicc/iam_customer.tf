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
