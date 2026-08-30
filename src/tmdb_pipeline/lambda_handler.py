import json
import os
import boto3

from tmdb_pipeline.tmdb_client import TMDBClient

secrets_client = boto3.client("secretsmanager")
s3_client = boto3.client("s3")

def lambda_handler(event, context):
    secret = secrets_client.get_secret_value(
        SecretId=os.environ["TMDB_SECRET_NAME"]
    )

    credentials = json.loads(secret["SecretString"])
    bearer_token = credentials["bearer_token"]

    client = TMDBClient(bearer_token)

    movies = client.fetch_movies("popular")

    s3_client.put_object(
        Bucket=os.environ["DATA_LAKE_BUCKET"],
        Key="raw/tmdb/popular/page=1.json",
        Body=json.dumps(movies),
        ContentType="application/json",
    )

    return {
        "statusCode": 200,
        "message": "TMDB popular movies ingested successfully",
    }