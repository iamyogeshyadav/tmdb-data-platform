resource "aws_iam_role" "redshift" {
  name = "tmdb-data-platform-redshift"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "redshift.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "redshift_s3" {
  name = "tmdb-data-platform-redshift-s3"
  role = aws_iam_role.redshift.name

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

        Resource = "${aws_s3_bucket.data_lake.arn}/transformed/*"
      }
    ]
  })
}

resource "aws_redshiftserverless_namespace" "tmdb" {
  namespace_name = "tmdb-data-platform"
  db_name        = "tmdb_warehouse"

  manage_admin_password = true

  iam_roles = [
    aws_iam_role.redshift.arn
  ]

  default_iam_role_arn = aws_iam_role.redshift.arn
}

resource "aws_redshiftserverless_workgroup" "tmdb" {
  workgroup_name = "tmdb-data-platform"
  namespace_name = aws_redshiftserverless_namespace.tmdb.namespace_name

  base_capacity = 4
}