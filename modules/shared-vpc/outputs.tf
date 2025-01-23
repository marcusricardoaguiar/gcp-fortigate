output "shared_vpc" {
  value = google_compute_network.shared_vpc
}

output "shared_vpc_subnets" {
  value = google_compute_subnetwork.shared_vpc_subnets
}

output "application_vms_cidr_range" {
  value = google_network_connectivity_internal_range.application_vms_cidr_range
}
