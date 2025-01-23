# Defining an internal range for the Shared VPC.
resource "google_network_connectivity_internal_range" "application_vms_cidr_range" {
  name          = "application-vms"
  project       = var.host_project
  description   = "CIDR range allocated for the VM subnets."
  network       = google_compute_network.shared_vpc.self_link
  usage         = "FOR_VPC"
  peering       = "FOR_SELF"
  ip_cidr_range = "10.10.0.0/16"
}
