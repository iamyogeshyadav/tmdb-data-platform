resource "aws_iam_role" "eventbridge_scheduler" {
  name = "tmdb-data-platform-eventbridge-scheduler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "scheduler.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_scheduler" {
  name = "tmdb-data-platform-eventbridge-scheduler-policy"
  role = aws_iam_role.eventbridge_scheduler.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "states:StartExecution"
      ]

      Resource = aws_sfn_state_machine.tmdb_pipeline.arn
    }]
  })
}

resource "aws_scheduler_schedule" "eventbridge_scheduler" {
  name = "tmdb-data-platform-eventbridge-scheduler"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 8 * * ? *)"
  schedule_expression_timezone = "Asia/Kolkata"

  target {
    arn      = aws_sfn_state_machine.tmdb_pipeline.arn
    role_arn = aws_iam_role.eventbridge_scheduler.arn

    input = jsonencode({})

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }

}

