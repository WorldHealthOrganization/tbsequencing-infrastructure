resource "aws_sns_topic" "step-func-fail" {
  name              = "${local.prefix}-step-func-fail-topic"
  kms_master_key_id = resource.aws_kms_key.sns_key.key_id

}

resource "aws_sns_topic_subscription" "step-func-fail" {
  topic_arn = resource.aws_sns_topic.step-func-fail.arn
  protocol  = "https"
  endpoint  = "https://global.sns-api.chatbot.amazonaws.com"
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "${local.prefix}-alarm-chatbot-sns-policy"

  statement {
    sid = "allow access by event bridge"

    actions = [
      "sns:Publish"
    ]
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.step-func-fail.arn,
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [resource.aws_cloudwatch_event_rule.step-function-failure-events.arn]
    }
  }
  statement {
    sid = "allow access by budget"
    actions = [
      "sns:Publish"
    ]
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.step-func-fail.arn,
    ]

  }

}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.step-func-fail.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}
