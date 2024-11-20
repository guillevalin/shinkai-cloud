provider "google" {
    project = var.project_id
    region  = var.region
}

variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

output "ollama_host" {
    description = "Ollama Instance Cloud Run Function"
    value = google_cloud_run_service.ollama_node.status
}

output "shinkai_host" {
    description = "Shinkai Insstance Cloud Run Function"
    value = google_cloud_run_service.shinkai_node.status
}