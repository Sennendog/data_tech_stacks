
-- Create an Iceberg table in BigQuery
CREATE TABLE datalake.iceberg_table (
    table_key string,
    table_value string
)
WITH CONNECTION `${connection_name}`
OPTIONS (
    file_format = 'PARQUET',
    table_format = 'ICEBERG',
    storage_uri = '${storage_uri}'
);
