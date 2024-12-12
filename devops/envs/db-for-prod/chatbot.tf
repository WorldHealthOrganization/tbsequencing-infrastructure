resource "aws_chatbot_teams_channel_configuration" "notif_channel" {
  tenant_id             = jsondecode(data.aws_secretsmanager_secret_version.ms_teams_current.secret_string)["TENANT_ID"]
  team_id               = jsondecode(data.aws_secretsmanager_secret_version.ms_teams_current.secret_string)["GROUP_ID"]
  channel_id            = jsondecode(data.aws_secretsmanager_secret_version.ms_teams_current.secret_string)["CHANNEL_ID"]
  channel_name          = "AWS db-for-prod env StepFunction failures"
  configuration_name    = "${local.prefix}-step-func-failure-teams-channel-notif"
  iam_role_arn          = aws_iam_role.chatbot_role.arn
  sns_topic_arns        = [resource.aws_sns_topic.step-func-fail.arn]
  guardrail_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  logging_level         = "INFO"
}

resource "aws_iam_role" "chatbot_role" {
  name = "${local.prefix}-alarm-chatbot-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "chatbot.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

