data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

locals {
  instance_url = var.domain_name != "" ? "https://${var.domain_name}" : "http://${google_compute_address.memos.address}"
  network_tags = concat([var.name], var.tags)
}

resource "google_compute_network" "memos" {
  name                    = "${var.name}-network"
  auto_create_subnetworks = true
}

resource "google_compute_address" "memos" {
  name   = "${var.name}-ip"
  region = var.region
}

resource "google_compute_firewall" "http_https" {
  name    = "${var.name}-allow-web"
  network = google_compute_network.memos.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.name]
}

resource "google_compute_firewall" "ssh" {
  name    = "${var.name}-allow-ssh"
  network = google_compute_network.memos.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allow_ssh_cidrs
  target_tags   = [var.name]
}

resource "google_compute_instance" "memos" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = local.network_tags

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = var.disk_size_gb
      type  = "pd-standard"
    }
  }

  network_interface {
    network = google_compute_network.memos.id

    access_config {
      nat_ip = google_compute_address.memos.address
    }
  }

  metadata_startup_script = templatefile("${path.module}/templates/startup.sh.tftpl", {
    instance_name = var.name
    instance_url  = local.instance_url
    repo_url      = var.repo_url
    repo_ref      = var.repo_ref
  })

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}
