# ================================================================================
# VPCs — one per region, non-overlapping CIDRs for full-mesh peering
# auto_create_subnetworks = false — subnets managed explicitly below
# ================================================================================

resource "google_compute_network" "vpc1" {
  name                    = "mesh-vpc1"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "mesh-subnet1"
  region        = "us-east1"
  network       = google_compute_network.vpc1.id
  ip_cidr_range = "10.0.0.0/28"
}

resource "google_compute_network" "vpc2" {
  name                    = "mesh-vpc2"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet2" {
  name          = "mesh-subnet2"
  region        = "us-east4"
  network       = google_compute_network.vpc2.id
  ip_cidr_range = "172.16.0.0/28"
}

resource "google_compute_network" "vpc3" {
  name                    = "mesh-vpc3"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet3" {
  name          = "mesh-subnet3"
  region        = "us-west2"
  network       = google_compute_network.vpc3.id
  ip_cidr_range = "192.168.0.0/28"
}
