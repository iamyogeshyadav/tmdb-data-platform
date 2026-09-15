resource "aws_iam_role" "step_functions" {
  name = "tmdb-data-platform-step-functions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "states.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "step_functions" {
  name = "tmdb-data-platform-step-functions-policy"
  role = aws_iam_role.step_functions.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetJobRuns",
          "glue:BatchStopJobRun"
        ]

        Resource = [
          aws_lambda_function.ingestion.arn,
          aws_glue_job.transform_movies.arn
        ]
      }
    ]
  })
}

resource "aws_sfn_state_machine" "tmdb_pipeline" {
  name     = "tmdb-data-platform-pipeline"
  role_arn = aws_iam_role.step_functions.arn

  definition = jsonencode({
    StartAt = "IngestMovies"

    States = {
      IngestMovies = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"

        Parameters = {
          FunctionName = aws_lambda_function.ingestion.arn
        }

        Next = "TransformMovies"
      }

      TransformMovies = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"

        Parameters = {
          JobName = aws_glue_job.transform_movies.name
        }

        End = true
      }
    }
  })
}