resource "aws_budgets_budget" "daily-cost" {
  # ...
  budget_type  = "COST"
  limit_amount = "5"
  limit_unit   = "USD"
  time_unit    = "DAILY"
  #Cost types must be defined for RI budgets because the settings conflict with the defaults

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = "100"
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [resource.aws_sns_topic.step-func-fail[0].arn]
  }
}
