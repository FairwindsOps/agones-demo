resource "google_game_services_game_server_deployment" "supertuxkart" {
  deployment_id = "supertuxkart"
  description   = "a deployment of supertuxkart gameservers"
}

# Rollout
resource "google_game_services_game_server_deployment_rollout" "supertuxkart" {
  deployment_id              = google_game_services_game_server_deployment.supertuxkart.deployment_id
  default_game_server_config = google_game_services_game_server_config.supertuxkart.name
  game_server_config_overrides {
    config_version = google_game_services_game_server_config.supertuxkart.id
    realms_selector {
      realms = ["${google_game_services_realm.us.id}"]
    }
  }
}


## Supertuxkart Config
resource "google_game_services_game_server_config" "supertuxkart" {
  config_id     = "supertuxkart"
  deployment_id = google_game_services_game_server_deployment.supertuxkart.deployment_id
  description   = "a deployment of supertuxkart gameservers"

  fleet_configs {
    name       = "supertuxkart"
    fleet_spec = jsonencode(yamldecode(file("supertuxkart-fleet.yaml")))
  }
  scaling_configs {
    name                  = "buffer"
    fleet_autoscaler_spec = jsonencode(yamldecode(file("autoscaler.yaml")))
  }
}
