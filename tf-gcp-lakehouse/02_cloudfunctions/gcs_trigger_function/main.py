import requests

FLINK_CONTROLLER_ENDPOINT = "https://flink-controller.yourdomain.com/ingest"

def gcs_file_trigger(event, context):
    file_path = f"gs://{event['bucket']}/{event['name']}"
    
    payload = {
        "gcs_file_path": file_path,
        "target_table": "mylake"
    }
    
    # Notify Flink controller to start job
    response = requests.post(FLINK_CONTROLLER_ENDPOINT, json=payload)
    
    if response.status_code != 200:
        raise RuntimeError(f"Failed to trigger Flink ingestion: {response.text}")
