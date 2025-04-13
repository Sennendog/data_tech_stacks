import os
import requests

FLINK_CONTROLLER_ENDPOINT = "https://flink-controller.yourdomain.com/ingest"

def gcs_file_trigger(event, context):
    file_name = event['name']
    
    # Only trigger on files under the /landingzone/ folder
    if not file_name.startswith("landingzone/"):
        print(f"Ignored file outside landing zone: {file_name}")
        return

    file_path = f"gs://{event['bucket']}/{file_name}"
    
    # Extract base filename without extension
    base_filename = os.path.basename(file_name)
    target_table, _ = os.path.splitext(base_filename)

    payload = {
        "gcs_file_path": file_path,
        "target_table": target_table
    }

    # Notify Flink controller to start job
    response = requests.post(FLINK_CONTROLLER_ENDPOINT, json=payload)

    if response.status_code != 200:
        raise RuntimeError(f"Failed to trigger Flink ingestion: {response.text}")
