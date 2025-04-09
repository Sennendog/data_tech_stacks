# Read the project ID from the file
$projectId = Get-Content -Path "../../../gcp-project-id" -Raw
$projectId = $projectId.Trim()  # Remove any trailing newline

# enable services
gcloud services enable cloudresourcemanager.googleapis.com --project $projectId

# Define the service account email
$serviceAccount = "datastacks-tf-sa@$projectId.iam.gserviceaccount.com"

# Define the roles to assign
$roles = @(
    "roles/storage.admin",
    "roles/cloudfunctions.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/pubsub.admin",
    "roles/dataproc.editor",
    "roles/bigquery.admin",
    "roles/biglake.admin",
    "roles/serviceusage.serviceUsageAdmin"
)

# Assign each role using gcloud
foreach ($role in $roles) {
    Write-Host "Assigning $role to $serviceAccount in project $projectId"
    & gcloud projects add-iam-policy-binding $projectId `
        --member="serviceAccount:$serviceAccount" `
        --role=$role
}
