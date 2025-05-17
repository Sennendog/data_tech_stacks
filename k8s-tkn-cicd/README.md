# k8x-tkn-cicd: Kubernetes setup with Tekton CI/CD pipeline

This project builds a data pipeline for streaming data ingestion using Apache Flink.

It uses Docker Compose to run an Apache Flink cluster in a containerized environment (locally or any cloud provider).
  
## Components:  
- **Minikube**: local kubernetes
- **Tekton**: kubernetes native CI/CD


## Requirements:  
 - see [Requirements.md](REQUIREMENTS.md)


## How to deploy and run:  
 - setup: [01_setup/setup.ps1](01_setup/setup.ps1)

  
## Architecture:  
![image](ARCHITECTURE.png)
