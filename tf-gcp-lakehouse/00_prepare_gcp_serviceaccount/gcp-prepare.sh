#!/bin/bash

# Read project ID from file
PROJECT_ID=$(<../../../gcp-project-id)

# Define service account email
SERVICE_ACCOUNT="terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com"

# Enable services
gcloud services enable cloudresourcemanager.googleapis.com --project "$projectId"
gcloud services enable iam.googleapis.com --project "$projectId"
gcloud services enable pubsub.googleapis.com --project "$projectId"
gcloud services enable cloudfunctions.googleapis.com --project "$projectId"
gcloud services enable storage-component.googleapis.com --project "$projectId"
gcloud services enable dataproc.googleapis.com --project "$projectId"
gcloud services enable bigquery.googleapis.com --project "$projectId"
gcloud services enable biglake.googleapis.com --project "$projectId"
gcloud services enable serviceusage.googleapis.com --project "$projectId"
gcloud services enable cloudbuild.googleapis.com --project "$projectId"
gcloud services enable run.googleapis.com --project "$projectId"


# Define the roles to assign
ROLES=(
    "roles/storage.admin"
    "roles/cloudfunctions.admin"
    "roles/iam.serviceAccountAdmin"
    "roles/iam.securityAdmin"
    "roles/pubsub.admin"
    "roles/dataproc.editor"
    "roles/bigquery.admin"
    "roles/biglake.admin"
    "roles/serviceusage.serviceUsageAdmin"
    "roles/iam.serviceAccountUser"
    "roles/resourcemanager.projectIamAdmin"
    "roles/viewer"
)

# Assign each role using gcloud
for ROLE in "${ROLES[@]}"; do
    echo "Assigning $ROLE to $SERVICE_ACCOUNT in project $PROJECT_ID"
    gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:${SERVICE_ACCOUNT}" --role="$ROLE"
done
