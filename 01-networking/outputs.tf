output "project_id" { value = local.project_id }

output "network1_name" { value = google_compute_network.vpc1.name }
output "network2_name" { value = google_compute_network.vpc2.name }
output "network3_name" { value = google_compute_network.vpc3.name }

output "subnet1_name" { value = google_compute_subnetwork.subnet1.name }
output "subnet2_name" { value = google_compute_subnetwork.subnet2.name }
output "subnet3_name" { value = google_compute_subnetwork.subnet3.name }
