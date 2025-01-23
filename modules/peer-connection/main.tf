resource "google_compute_network_peering" "hub_to_spoke" {
  name                 = "peer-fgthub-to-${var.shared_vpc_name}-${var.shared_vpc_project}"
  network              = var.fortigate_internal_vpc_self_link
  peer_network         = var.shared_vpc_self_link
  export_custom_routes = true
}

resource "google_compute_network_peering" "spoke_to_hub" {
  name                 = "peer-${var.shared_vpc_name}-${var.shared_vpc_project}-to-fgthub"
  network              = var.shared_vpc_self_link
  peer_network         = var.fortigate_internal_vpc_self_link
  import_custom_routes = true
  depends_on           = [
    google_compute_network_peering.hub_to_spoke
  ]
}
