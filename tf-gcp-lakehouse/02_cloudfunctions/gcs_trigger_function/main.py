import os
import requests
from cloudevents.http import CloudEvent
import functions_framework

FLINK_CONTROLLER_ENDPOINT = "https://flink-controller.yourdomain.com/ingest"


@functions_framework.cloud_event
def gcs_file_trigger(cloud_event: CloudEvent):
    """Triggered by a change in a storage bucket."""

    print(f"gcs_file_trigger CloudEvent: {cloud_event}")
    message_attributes = cloud_event.data.get("message", {}).get("attributes", {})
    object_id = message_attributes.get("objectId")

    file_name = object_id
        
    # Extract base filename without extension
    base_filename = os.path.basename(file_name)
    target_table, _ = os.path.splitext(base_filename)

    payload = {
        "gcs_file_path": file_name,
        "target_table": target_table
    }

    # Notify Flink controller to start job
    print(f"Triggering Flink ingestion with payload: {payload}")
    response = requests.post(FLINK_CONTROLLER_ENDPOINT, json=payload)

    if response.status_code != 200:
        raise RuntimeError(f"Failed to trigger Flink ingestion: {response.text}")
