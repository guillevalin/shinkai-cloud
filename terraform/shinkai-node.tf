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
                    value = "http://localhost:11434"
                }
                env {
                    name  = "FIRST_DEVICE_NEEDS_REGISTRATION_CODE"
                    value = "false"
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