# ================================================================================
# Firewall Rules — one set per VPC
# HTTP allowed from all three VPC CIDRs; SSH allowed from IAP proxy range only
# ================================================================================

resource "google_compute_firewall" "allow_http_vpc1" {
  name    = "mesh-allow-http-vpc1"
  network = var.network1_name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["10.0.0.0/28", "172.16.0.0/28", "192.168.0.0/28"]
}

resource "google_compute_firewall" "allow_iap_ssh_vpc1" {
  name    = "mesh-allow-iap-ssh-vpc1"
  network = var.network1_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IAP tunnels SSH through this well-known Google proxy range
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "allow_http_vpc2" {
  name    = "mesh-allow-http-vpc2"
  network = var.network2_name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["10.0.0.0/28", "172.16.0.0/28", "192.168.0.0/28"]
}

resource "google_compute_firewall" "allow_iap_ssh_vpc2" {
  name    = "mesh-allow-iap-ssh-vpc2"
  network = var.network2_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "allow_http_vpc3" {
  name    = "mesh-allow-http-vpc3"
  network = var.network3_name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["10.0.0.0/28", "172.16.0.0/28", "192.168.0.0/28"]
}

resource "google_compute_firewall" "allow_iap_ssh_vpc3" {
  name    = "mesh-allow-iap-ssh-vpc3"
  network = var.network3_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}
