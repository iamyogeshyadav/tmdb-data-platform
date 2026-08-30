resource "aws_secretsmanager_secret" "tmdb" {
  name = "tmdb-data-platform-api-credentials"
}