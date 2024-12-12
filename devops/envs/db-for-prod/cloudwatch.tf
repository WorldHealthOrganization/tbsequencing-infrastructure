locals {
  service_name = local.prefix
  cw_log_group = "/aws/ecs/${local.prefix}"
}

resource "aws_cloudwatch_log_group" "backend_fargate_task" {
  name = "${local.cw_log_group}-backend"
  tags = {
    Name = "${local.service_name}-backend",
  }
}

resource "aws_cloudwatch_log_group" "migration_fargate_task" {
  name = "${local.cw_log_group}-backend-migrations"
  tags = {
    Name = "${local.service_name}-backend-migrations",
  }
}

resource "aws_cloudwatch_log_group" "django-delegate" {
  name = "/backend/delegate-activity"
  tags = {
    Name = "${local.service_name}-django-delegate",
  }
}

resource "aws_cloudwatch_log_group" "django-admin" {
  name = "/backend/admin-activity"
  tags = {
    Name = "${local.service_name}-django-admin",
  }
}
resource "aws_cloudwatch_log_group" "django-server" {
  name = "/backend/server"
  tags = {
    Name = "${local.service_name}-django-server",
  }
}

resource "aws_cloudwatch_event_rule" "step-function-failure-events" {
  name        = "${local.service_name}-step-func-fail-abort-event"
  description = "Capture each AWS Step Function failure or abort"
  event_pattern = jsonencode({
    source = ["aws.states"]
    detail-type = [
      "Step Functions Execution Status Change"
    ]
    detail = {
      status = ["FAILED", "TIMED_OUT", "ABORTED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "sns-target-rule" {
  rule = resource.aws_cloudwatch_event_rule.step-function-failure-events.name
  arn  = resource.aws_sns_topic.step-func-fail.arn
  input_transformer {
    input_paths = {
      "exec" : "$.detail.name",
      "machine" : "$.detail.stateMachineArn",
      "region" : "$.region",
      "status" : "$.detail.status",
      "time" : "$.time",
      "url" : "$.detail.executionArn"
    }
    input_template = <<EOF
    {
    "version": "1.0",
    "source": "custom",
    "textType": "client-markdown",
    "content": {
      "description": "**Execution** [<exec>](https://<region>.console.aws.amazon.com/states/home?region=<region>#/v2/executions/details/<url>)",
      "title": ":warning: <machine> <status> at <time> :warning:"
      }
    }
  EOF
  }
}

