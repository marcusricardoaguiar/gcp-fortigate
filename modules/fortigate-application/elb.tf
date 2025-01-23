/*
  This file creates the resources required to deploy the External Load Balancer for Fortigate.
  It is going to be the entry point for every request to the VMs inside GCP.
*/

resource "google_compute_address" "elb_eip" {
  name    = "${var.prefix}eip-${local.region_short}"
  project = var.project
  region  = var.region
}

resource "google_compute_forwarding_rule" "elb_frule" {
  name                  = "${var.prefix}fwdrule"
  region                = var.region
  project               = var.project
  ip_address            = google_compute_address.elb_eip.self_link
  ip_protocol           = "L3_DEFAULT"
  all_ports             = true
  load_balancing_scheme = "EXTERNAL"
  backend_service       = google_compute_region_backend_service.elb_bes.self_link
}

resource "google_compute_region_backend_service" "elb_bes" {
  provider              = google-beta
  project               = var.project
  name                  = "${var.prefix}bes-elb-${var.region}"
  region                = var.region
  protocol              = "UNSPECIFIED"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_compute_instance_group.fgt-umigs[0].self_link
    balancing_mode = "CONNECTION"
  }
  backend {
    group = google_compute_instance_group.fgt-umigs[1].self_link
    balancing_mode = "CONNECTION"
  }

  health_checks = [google_compute_region_health_check.health_check.self_link]
  connection_tracking_policy {
    connection_persistence_on_unhealthy_backends = "NEVER_PERSIST"
  }
}

resource "google_compute_route" "default_route" {
  name         = "${var.prefix}rt-default-via-fgt"
  project      = var.project
  dest_range   = "0.0.0.0/0"
  network      = var.subnets["internal"].network
  next_hop_ilb = google_compute_forwarding_rule.ilb_fwd_rule.self_link
  priority     = 100
}
