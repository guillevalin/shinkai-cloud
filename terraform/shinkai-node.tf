resource "google_cloud_run_service" "shinkai_node" {
    name     = "shinkai-node"
    location = "us-central1"

    template {
        spec {
            containers {
                image = "guillevalin/shinkai-node:latest"
                ports {
                    container_port = 9550
                }
                resources {
                    limits = {
                        memory = "8Gi"
                        cpu    = "2000m"
                    }
                }
                env {
                    name  = "EMBEDDINGS_SERVER_URL"
                    value = "https://OLLAMA-INSTANCE.REGION.run.app"
                }
                env {
                    name  = "FIRST_DEVICE_NEEDS_REGISTRATION_CODE"
                    value = "false"
                }
                env {
                    name  = "LOG_SIMPLE"
                    value = "true"
                }
                env {
                    name  = "NO_SECRET_FILE"
                    value = "true"
                }
                env {
                    name  = "REINSTALL_TOOLS"
                    value = "true"
                }
                env {
                    name  = "API_V2_KEY"
                    value = "REPLACE_WITH_API_KEY"
                }
                env {
                    name  = "INITIAL_AGENTS_URLS"
                    value = "https://OLLAMA-INSTANCE.REGION.run.app"
                }
                env {
                    name  = "INITIAL_AGENT_MODELS"
                    value = "ollama:llama3.1:8b-instruct-q4_1"
                }
                env {
                    name  = "INITIAL_AGENT_NAMES"
                    value = "o_llama3_1_8b_instruct_q4_1"
                }
                env {
                    name  = "DEFAULT_EMBEDDING_MODEL"
                    value = "snowflake-arctic-embed:xs"
                }
                env {
                    name  = "SUPPORTED_EMBEDDING_MODELS"
                    value = "snowflake-arctic-embed:xs"
                }
            }
        }
        metadata {
            annotations = {
                "autoscaling.knative.dev/minScale" = "0"
                "autoscaling.knative.dev/maxScale" = "10"
                "run.googleapis.com/cpu-throttling" = "true"
                "run.googleapis.com/startup-cpu-boost" = "true"
            }
        }
    }

    traffic {
        percent         = 100
        latest_revision = true
    }
}

resource "google_cloud_run_service_iam_member" "shinkai_invoker" {
    service = google_cloud_run_service.shinkai_node.name
    location = google_cloud_run_service.shinkai_node.location
    role    = "roles/run.invoker"
    member  = "allUsers"
}