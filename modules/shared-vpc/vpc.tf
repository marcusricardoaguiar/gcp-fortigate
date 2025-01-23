resource "google_compute_shared_vpc_host_project" "host" {
  project = var.host_project
}

resource "google_compute_shared_vpc_service_project" "service1" {
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = var.service_project
}

resource "google_compute_network" "shared_vpc" {
  project                 = var.host_project
  name                    = "${var.prefix}sharedvpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "shared_vpc_subnets" {
  for_each                = var.shared_subnets
  project                 = var.host_project
  name                    = "${var.prefix}sharedvpc-${each.key}"
  network                 = google_compute_network.shared_vpc.self_link
  reserved_internal_range = "networkconnectivity.googleapis.com/${google_network_connectivity_internal_range.application_vms_cidr_range.id}"
  ip_cidr_range           = each.value
}
