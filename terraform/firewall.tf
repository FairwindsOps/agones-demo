resource "google_compute_firewall" "allow_game_server_blue" {
  name        = "game-server-${local.network_name_blue}"
  description = "Allows the TCP port range for the game servers."
  network     = local.network_name_blue
  target_tags = ["game-server"]

  allow {
    protocol = "tcp"
    ports    = ["7000-8000"]
  }
}

resource "google_compute_firewall" "allow_game_server_green" {
  name        = "game-server-${local.network_name_green}"
  description = "Allows the TCP port range for the game servers."
  network     = local.network_name_green
  target_tags = ["game-server"]

  allow {
    protocol = "tcp"
    ports    = ["7000-8000"]
  }
}
