resource "aws_chatbot_teams_channel_configuration" "sequencing_channel_config" {
  tenant_id             = data.aws_ssm_parameter.ms_teams_tenant_id.value
  team_id               = data.aws_ssm_parameter.ms_teams_group_id.value
  channel_id            = data.aws_ssm_parameter.ms_teams_channel_id.value
  channel_name          = "AWS db-for-prod env StepFunction failures"
  configuration_name    = "${local.prefix}-step-func-failure-teams-channel-notif"
  iam_role_arn          = aws_iam_role.chatbot_role.arn
  sns_topic_arns        = [resource.aws_sns_topic.step-func-fail.arn]
  guardrail_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
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
