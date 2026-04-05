output "public_ip" {
  description = "Reserved public IP address of the Memos VM."
  value       = google_compute_address.memos.address
}

output "instance_url" {
  description = "Base URL configured for the Memos instance."
  value       = local.instance_url
}

output "ssh_command" {
  description = "Example SSH command once OS Login access is configured."
  value       = "gcloud compute ssh ${google_compute_instance.memos.name} --project ${var.project_id} --zone ${var.zone}"
}
