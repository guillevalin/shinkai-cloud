# Project Overview

This project deploys and manages two Google Cloud Run services: `shinkai-node` and `ollama-node`. The deployment is managed using Terraform, and Docker is used to build the container images for these services.

## How to install and configure gcloud CLI

1. Install the Google Cloud CLI by following the instructions [here](https://cloud.google.com/sdk/docs/install).

2. After installation, initialize the gcloud CLI:
```sh
gcloud init
```

3. Follow the prompts to log in with your Google account and select your Google Cloud project.

4. Set the project you want to use:
```sh
gcloud config set project <your-project-id>
```

5. Make sure you have the necessary permissions to deploy resources in your Google Cloud project.

6. Authenticate Docker to your Google Container Registry:
```sh
gcloud auth configure-docker
```

## How to build Docker images

1. Navigate to the directory containing the Dockerfile for the service you want to build.

2. Run the following command to build the Docker image:
```sh
docker build --platform linux/amd64 --build-arg OLLAMA_VERSION=v0.4.2 -f docker/Dockerfile.ollama -t gcr.io/<your-project-id>/ollama-node:v0.4.2 .
docker build --platform linux/amd64 --build-arg SHINKAI_NODE_VERSION=v0.8.16 -f docker/Dockerfile.shinkai -t gcr.io/<your-project-id>/shinkai-node:v0.8.16 .
```

3. Push the Docker image to Google Container Registry:
```sh
docker push gcr.io/<your-project-id>/shinkai-node:v0.8.16
docker push gcr.io/<your-project-id>/ollama-node:v0.4.2
```

## How to deploy with Terraform
This project will deploy two Google Cloud Run functions, one for the Ollama container and another for the Shinkai Node container, you need to have your Google Cloud CLI configured and a project available for deploy.

1. Initialize Terraform:
```sh
terraform init
```

2. Apply the Terraform configuration:
```sh
terraform apply
```

3. Confirm the apply action with `yes`.

## Variables

- `project_id`: The Google Cloud project ID.
- `region`: The region where the services will be deployed.

## Outputs

- `ollama_host`: The URL of the deployed `ollama-node` service.
- `shinkai_host`: The URL of the deployed `shinkai-node` service.