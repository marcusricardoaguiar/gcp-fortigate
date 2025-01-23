resource "google_compute_network" "vpcs" {
  for_each                = toset(var.networks)
  project                 = var.project
  name                    = "${var.prefix}vpc-${each.key}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnets" {
  for_each      = toset(var.networks)
  project       = var.project
  name          = "${var.prefix}sb-${each.key}"
  network       = google_compute_network.vpcs[each.key].self_link
  ip_cidr_range = "${var.ip_cidr_2oct}.${index(var.networks, each.value)}.0/24"

  log_config {
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
