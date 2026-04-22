# ================================================================================
# GCE VMs — one per VPC
# Debian 12, no external IP; nginx serves identity response via startup script
# gcloud compute ssh --tunnel-through-iap replaces SSM for out-of-band execution
# ================================================================================

resource "google_compute_instance" "vm1" {
  name         = "mesh-vm1"
  machine_type = "e2-micro"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = var.network1_name
    subnetwork = var.subnet1_name
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    IP=$(hostname -I | awk '{print $1}')
    echo "$IP - Welcome to VPC us-east1" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
}

resource "google_compute_instance" "vm2" {
  name         = "mesh-vm2"
  machine_type = "e2-micro"
  zone         = "us-east4-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = var.network2_name
    subnetwork = var.subnet2_name
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    IP=$(hostname -I | awk '{print $1}')
    echo "$IP - Welcome to VPC us-east4" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
}

resource "google_compute_instance" "vm3" {
  name         = "mesh-vm3"
  machine_type = "e2-micro"
  zone         = "us-west2-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = var.network3_name
    subnetwork = var.subnet3_name
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    IP=$(hostname -I | awk '{print $1}')
    echo "$IP - Welcome to VPC us-west2" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
}
