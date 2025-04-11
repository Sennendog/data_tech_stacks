# tf-gcp-lakehouse: Terraform - GCP provisioning of Data Lakehouse  

This project builds a Data Lakehouse architecture with storage/compute separation using BigQuery and Apache Iceberg open storage format.  

It uses Cloud Functions + Apache Flink + BigQuery BigLake Iceberg for an event-driven and streaming-friendly architecture, leverageing GCP-native services and Flink for scalable ingestion.  
  
## Components:  
- **GCS**: storage for raw data (landingzone) and Iceberg tables
- **Pub/sub** and **Cloud Function**: Trigger for ingestion jobs
- **Apache Flink (via Dataproc)**:  Ingests files and writes to Iceberg tables
- **BigQuery BigLake**: Iceberg catalog
- **BigQuery**: Query engine
  
  
## Architecture:  
![image](ARCHITECTURE.png)
