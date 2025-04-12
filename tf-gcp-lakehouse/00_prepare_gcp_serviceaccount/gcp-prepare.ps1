# Read the project ID from the file
$projectId = Get-Content -Path "../../../gcp-project-id" -Raw
$projectId = $projectId.Trim()  # Remove any trailing newline

# enable services
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


# Define the service account email
$serviceAccount = "terraform-sa@$projectId.iam.gserviceaccount.com"

# Define the roles to assign
$roles = @(
    "roles/storage.admin",
    "roles/cloudfunctions.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.securityAdmin",
    "roles/pubsub.admin",
    "roles/dataproc.editor",
    "roles/bigquery.admin",
    "roles/biglake.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/iam.serviceAccountUser",
    "roles/resourcemanager.projectIamAdmin",
    "roles/viewer"
)

# Assign each role using gcloud
foreach ($role in $roles) {
    Write-Host "Assigning $role to $serviceAccount in project $projectId"
    & gcloud projects add-iam-policy-binding "$projectId" --member="serviceAccount:$serviceAccount" --role=$role
}
