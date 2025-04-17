import argparse
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType


parser = argparse.ArgumentParser()
parser.add_argument("--input", required=True, help="Input file path on GCS")
parser.add_argument("--table", required=True, help="Target BigQuery table (project.dataset.table)")
parser.add_argument("--bucket", required=True, help="temp_gcs_bucket for BigLake")
args = parser.parse_args()

spark = SparkSession.builder.appName("IngestToBigLake").getOrCreate()

schema = StructType([
    StructField("table_key", StringType(), True),
    StructField("table_value", StringType(), True),
])

# Read the file
df = spark.read.schema(schema).csv(args.input)

# Write to BigQuery (BigLake)
df.write \
    .format("bigquery") \
    .option("table", args.table) \
    .option("temporaryGcsBucket", args.bucket) \
    .mode("append") \
    .save()
