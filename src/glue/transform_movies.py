import sys

from awsglue.context import GlueContext
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql.functions import col, explode


args = getResolvedOptions(
    sys.argv,
    ["DATA_LAKE_BUCKET"],
)

spark_context = SparkContext.getOrCreate()
glue_context = GlueContext(spark_context)
spark = glue_context.spark_session

# raw_path = f"s3://{args['DATA_LAKE_BUCKET']}/raw/tmdb/popular/"
raw_path = f"s3://{args['DATA_LAKE_BUCKET']}/raw/tmdb/popular/page=1.json"
transformed_path = f"s3://{args['DATA_LAKE_BUCKET']}/transformed/movies/"

# movies = spark.read.json(raw_path)
movies = (
    spark.read
    .option("multiLine", "true")
    .json(raw_path)
)

movies.printSchema()

movies = movies.select(
    explode(col("results")).alias("movie")
)

movies = movies.select(
    col("movie.id").alias("id"),
    col("movie.title").alias("title"),
    col("movie.original_language").alias("original_language"),
    col("movie.release_date").alias("release_date"),
    col("movie.popularity").alias("popularity"),
    col("movie.vote_average").alias("vote_average"),
    col("movie.vote_count").alias("vote_count"),
)

movies.write.mode("overwrite").parquet(transformed_path)