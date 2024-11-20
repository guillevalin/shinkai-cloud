resource "google_cloud_run_service" "ollama_node" {
    name     = "ollama-node"
    location = "us-central1"

    template {
        spec {
            containers {
                image = "guillevalin/ollama:latest"
                ports {
                    container_port = 9550
                }
                resources {
                    limits = {
                        memory = "16Gi"
                        cpu    = "4000m"
                        #"nvidia.com/gpu" = "1"
                    }
                }
                env {
                    name  = "OLLAMA_HOST"
                    value = "0.0.0.0"
                }
            }
            #node_selector = {
            #    "run.googleapis.com/accelerator" = "nvidia-l4"
            #}
        }
        metadata {
            annotations = {
                "autoscaling.knative.dev/minScale" = "0"
                "autoscaling.knative.dev/maxScale" = "2"
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

resource "google_cloud_run_service_iam_member" "ollama_invoker" {
    service = google_cloud_run_service.ollama_node.name
    location = google_cloud_run_service.ollama_node.location
    role    = "roles/run.invoker"
    member  = "allUsers"
}