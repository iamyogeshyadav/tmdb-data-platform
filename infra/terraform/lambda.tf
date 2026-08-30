resource "aws_lambda_function" "ingestion" {
  function_name = "tmdb-data-platform-ingestion"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  role    = aws_iam_role.lambda_ingestion.arn
  handler = "tmdb_pipeline.lambda_handler.lambda_handler"
  runtime = "python3.14"

  timeout     = 60
  memory_size = 256

  environment {
    variables = {
      TMDB_SECRET_NAME = aws_secretsmanager_secret.tmdb.name
      DATA_LAKE_BUCKET = aws_s3_bucket.data_lake.bucket
    }
  }
}