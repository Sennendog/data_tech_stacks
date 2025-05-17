# Prerequisite: minikube is installed
minikube start
kubectl cluster-info

# Install the latest version of Tekton Pipelines
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Install Tekton Dashboard
kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml

# should list pods: tekton-dashboard, tekton-pipelines-controller, tekton-pipelines-webhook tekton-events-controller
kubectl get pods --namespace tekton-pipelines

# Open the dashboard in your browser (http://127.0.0.1:9097)
kubectl --namespace tekton-pipelines port-forward svc/tekton-dashboard 9097:9097

# Apply tekton pipeline
kubectl apply --filename 02_tekton/dbt-task.yaml
kubectl apply --filename 02_tekton/dbt-pipeline.yaml

# List pipelines
tkn pipeline list

# List pipeline runs
tkn pr list

# Start a new pipeline run
tkn pipeline start dbt-pipeline --showlog

