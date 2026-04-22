output "vm1_name"       { value = google_compute_instance.vm1.name }
output "vm2_name"       { value = google_compute_instance.vm2.name }
output "vm3_name"       { value = google_compute_instance.vm3.name }

output "vm1_zone"       { value = google_compute_instance.vm1.zone }
output "vm2_zone"       { value = google_compute_instance.vm2.zone }
output "vm3_zone"       { value = google_compute_instance.vm3.zone }

output "vm1_private_ip" { value = google_compute_instance.vm1.network_interface[0].network_ip }
output "vm2_private_ip" { value = google_compute_instance.vm2.network_interface[0].network_ip }
output "vm3_private_ip" { value = google_compute_instance.vm3.network_interface[0].network_ip }
