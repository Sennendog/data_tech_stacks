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
        # Decode Pub/Sub message
        data = cloud_event.data
        if 'data' not in data:
            raise ValueError("Missing 'data' field in Pub/Sub message.")

        message = json.loads(
            base64.b64decode(data['data']).decode('utf-8')
        )

        bucket = message['bucket']
        name = message['name']
        gcs_path = f"gs://{bucket}/{name}"

        # Read from environment
        project = os.environ["PROJECT_ID"]
        region = os.environ["REGION"]
        pyspark_script_uri = os.environ["PYSPARK_URI"]
        target_table = os.environ["TARGET_TABLE"]

        credentials, _ = default()
        dataproc = build("dataproc", "v1", credentials=credentials)

        timestamp = datetime.utcnow().strftime("%Y%m%d%H%M%S")
        job_id = f"biglake-ingest-{name.replace('/', '-').replace('.', '-')[:30]}-{timestamp}"

        job_payload = {
            "pysparkJob": {
                "mainPythonFileUri": pyspark_script_uri,
                "args": [
                    "--input", gcs_path,
                    "--bucket", bucket,
                    "--table", target_table
                ]
            },
            "labels": {
                "trigger": "cloud-function"
            },
            "placement": {
                "clusterSelector": {
                    "clusterLabels": {
                        "env": "serverless"
                    }
                }
            }
        }

        request = dataproc.projects().locations().batches().create(
            parent=f"projects/{project}/locations/{region}",
            body={
                "batchId": job_id,
                "runtimeConfig": {
                    "version": "2.1"
                },
                **job_payload
            }
        )

        print(f"Dataproc Serverless batch to be submitted: {request}")
        # response = request.execute()
        # print(f"Submitted Dataproc Serverless batch: {response['name']}")

    except Exception as e:
        print(f"Error processing CloudEvent: {e}")
        raise
