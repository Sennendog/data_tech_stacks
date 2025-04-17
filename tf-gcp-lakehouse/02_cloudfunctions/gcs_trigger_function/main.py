import os
import json
import base64
from datetime import datetime
import functions_framework
from cloudevents.http import CloudEvent
from google.auth import default
from googleapiclient.discovery import build


@functions_framework.cloud_event
def gcs_file_trigger(cloud_event: CloudEvent):
    try:
        # Get the raw event data
        event_data = cloud_event.data  # this is a dict
        pubsub_message = event_data['message']
        print(f"Received Pub/Sub message: {pubsub_message}")

        # Decode the base64-encoded "data" field
        if 'data' not in pubsub_message:
            raise ValueError("Missing 'data' field in Pub/Sub message.")

        payload_json = base64.b64decode(pubsub_message['data']).decode('utf-8')
        payload = json.loads(payload_json)

        # Access useful fields
        bucket = payload.get("bucket")
        name = payload.get("name")
        gcs_path = f"gs://{bucket}/{name}"


        # Read from environment
        project = os.environ["PROJECT_ID"]
        region = os.environ["REGION"]
        pyspark_script_uri = os.environ["PYSPARK_URI"]
        target_table = os.environ["TARGET_TABLE"]
        tmp_bucket = os.environ["TMP_BUCKET"]

        credentials, _ = default()
        dataproc = build("dataproc", "v1", credentials=credentials)

        timestamp = datetime.utcnow().strftime("%Y%m%d%H%M%S")
        job_id = f"biglake-ingest-{timestamp}"

        job_payload = {
            "pysparkBatch": {
                "mainPythonFileUri": pyspark_script_uri,
                "args": [
                    "--input", gcs_path,
                    "--bucket", tmp_bucket,
                    "--table", target_table
                ]
            }
        }


        print(f"Dataproc Serverless batch to be submitted: {job_payload}")
        request = dataproc.projects().locations().batches().create(
            parent=f"projects/{project}/locations/{region}",
            batchId=job_id,
            body=job_payload
        )
        request.execute()
        print(f"Dataproc Serverless batch submitted")

    except Exception as e:
        print(f"Error processing CloudEvent: {e}")
        raise
