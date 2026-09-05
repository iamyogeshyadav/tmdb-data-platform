resource "aws_iam_role" "glue" {
  name = "tmdb-data-platform-glue"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "glue.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "glue" {
  name = "tmdb-data-platform-glue-policy"
  role = aws_iam_role.glue.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.data_lake.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]

        Resource = [
      "${aws_s3_bucket.data_lake.arn}/raw/*",
      "${aws_s3_bucket.data_lake.arn}/scripts/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.data_lake.arn}/transformed/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_glue_job" "transform_movies" {
  name     = "tmdb-data-platform-transform-movies"
  role_arn = aws_iam_role.glue.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.data_lake.bucket}/scripts/glue/transform_movies.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"     = "python"
    "--DATA_LAKE_BUCKET" = aws_s3_bucket.data_lake.bucket
  }

  glue_version      = "5.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  depends_on = [
  aws_s3_object.glue_script]

  timeout = 8

}

resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.data_lake.bucket
  key    = "scripts/glue/transform_movies.py"
  source = "${path.module}/../../src/glue/transform_movies.py"

  etag = filemd5("${path.module}/../../src/glue/transform_movies.py")
}