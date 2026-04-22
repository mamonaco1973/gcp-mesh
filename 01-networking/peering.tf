# ================================================================================
# VPC Peering — full mesh, 6 resources (2 per pair, one each direction)
# GCP peering is non-transitive — all 3 pairs required for full connectivity
# ================================================================================

resource "google_compute_network_peering" "vpc1_to_vpc2" {
  name         = "mesh-vpc1-to-vpc2"
  network      = google_compute_network.vpc1.self_link
  peer_network = google_compute_network.vpc2.self_link
}

resource "google_compute_network_peering" "vpc2_to_vpc1" {
  name         = "mesh-vpc2-to-vpc1"
  network      = google_compute_network.vpc2.self_link
  peer_network = google_compute_network.vpc1.self_link
}

resource "google_compute_network_peering" "vpc1_to_vpc3" {
  name         = "mesh-vpc1-to-vpc3"
  network      = google_compute_network.vpc1.self_link
  peer_network = google_compute_network.vpc3.self_link
}

resource "google_compute_network_peering" "vpc3_to_vpc1" {
  name         = "mesh-vpc3-to-vpc1"
  network      = google_compute_network.vpc3.self_link
  peer_network = google_compute_network.vpc1.self_link
}

resource "google_compute_network_peering" "vpc2_to_vpc3" {
  name         = "mesh-vpc2-to-vpc3"
  network      = google_compute_network.vpc2.self_link
  peer_network = google_compute_network.vpc3.self_link
}

resource "google_compute_network_peering" "vpc3_to_vpc2" {
  name         = "mesh-vpc3-to-vpc2"
  network      = google_compute_network.vpc3.self_link
  peer_network = google_compute_network.vpc2.self_link
}
