# ================================================================================
# Cloud Routers and NAT Gateways — one per VPC
# Each VPC handles its own outbound internet — no centralized NAT
# ================================================================================

resource "google_compute_router" "router1" {
  name    = "mesh-router1"
  region  = "us-east1"
  network = google_compute_network.vpc1.id
}

resource "google_compute_router_nat" "nat1" {
  name                               = "mesh-nat1"
  router                             = google_compute_router.router1.name
  region                             = "us-east1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_router" "router2" {
  name    = "mesh-router2"
  region  = "us-east4"
  network = google_compute_network.vpc2.id
}

resource "google_compute_router_nat" "nat2" {
  name                               = "mesh-nat2"
  router                             = google_compute_router.router2.name
  region                             = "us-east4"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_router" "router3" {
  name    = "mesh-router3"
  region  = "us-west2"
  network = google_compute_network.vpc3.id
}

resource "google_compute_router_nat" "nat3" {
  name                               = "mesh-nat3"
  router                             = google_compute_router.router3.name
  region                             = "us-west2"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
