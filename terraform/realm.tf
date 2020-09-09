resource "google_game_services_realm" "us" {
  realm_id  = "united-states"
  time_zone = "PST8PDT"
  location  = "global"

  description = "US Game Players"
}
