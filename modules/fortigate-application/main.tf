data "google_compute_image" "fgt_image" {
  project         = "fortigcp-project-001"
  # This image will use Pay as You Go option
  family          = "fortigate-70-payg"
}

# Pull default zones and the service account. Both can be overridden in variables if needed.
data "google_compute_zones" "zones_in_region" {
  region          = var.region
}

data "google_compute_default_service_account" "default" {
}

locals {
  zones = [
    var.zones[0]  != "" ? var.zones[0] : data.google_compute_zones.zones_in_region.names[0],
    var.zones[1]  != "" ? var.zones[1] : data.google_compute_zones.zones_in_region.names[1]
  ]
}

# We'll use shortened region and zone names for some resource names. This is a standard shorting described in
# GCP security foundations.
locals {
  region_short    = replace( replace( replace( replace(var.region, "europe-", "eu"), "australia", "au" ), "northamerica", "na"), "southamerica", "sa")
  zones_short     = [
    replace( replace( replace( replace(local.zones[0], "europe-", "eu"), "australia", "au" ), "northamerica", "na"), "southamerica", "sa"),
    replace( replace( replace( replace(local.zones[1], "europe-", "eu"), "australia", "au" ), "northamerica", "na"), "southamerica", "sa")
  ]
}

# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length                 = 30
  special                = false
  numeric                = true
}

# Create FortiGate instances with secondary logdisks and configuration. Everything 2 times (active + passive)
resource "google_compute_disk" "logdisk" {
  count                  = 2
  project                = var.project
  name                   = "${var.prefix}disk-logdisk${count.index+1}-${local.zones_short[count.index]}"
  size                   = 30
  type                   = "pd-ssd"
  zone                   = local.zones[count.index]
}

locals {
  config_active          = templatefile("${path.module}/fgt-base-config.tpl", {
    hostname               = "${var.prefix}vm-${local.zones_short[0]}"
    unicast_peer_ip        = google_compute_address.hasync_priv[1].address
    unicast_peer_netmask   = cidrnetmask(var.subnets["hasync"].ip_cidr_range)
    ha_prio                = 1
    healthcheck_port       = var.healthcheck_port
    api_key                = random_string.api_key.result
    ext_ip                 = google_compute_address.ext_priv[0].address
    ext_gw                 = var.subnets["external"].gateway_address
    int_ip                 = google_compute_address.int_priv[0].address
    int_gw                 = var.subnets["internal"].gateway_address
    int_cidr               = var.subnets["internal"].ip_cidr_range
    hasync_ip              = google_compute_address.hasync_priv[0].address
    mgmt_ip                = google_compute_address.mgmt_priv[0].address
    mgmt_gw                = var.subnets["mgmt"].gateway_address
    ilb_ip                 = google_compute_address.ilb.address
  })

  config_passive         = templatefile("${path.module}/fgt-base-config.tpl", {
    hostname               = "${var.prefix}vm-${local.zones_short[1]}"
    unicast_peer_ip        = google_compute_address.hasync_priv[0].address
    unicast_peer_netmask   = cidrnetmask(var.subnets["hasync"].ip_cidr_range)
    ha_prio                = 0
    healthcheck_port       = var.healthcheck_port
    api_key                = random_string.api_key.result
    ext_ip                 = google_compute_address.ext_priv[1].address
    ext_gw                 = var.subnets["external"].gateway_address
    int_ip                 = google_compute_address.int_priv[1].address
    int_gw                 = var.subnets["internal"].gateway_address
    int_cidr               = var.subnets["internal"].ip_cidr_range
    hasync_ip              = google_compute_address.hasync_priv[1].address
    mgmt_ip                = google_compute_address.mgmt_priv[1].address
    mgmt_gw                = var.subnets["mgmt"].gateway_address
    ilb_ip                 = google_compute_address.ilb.address
  })

}

resource "google_compute_instance" "fgt-vm" {
  count                  = 2
  project                = var.project
  zone                   = local.zones[count.index]
  name                   = "${var.prefix}vm${count.index+1}-${local.zones_short[count.index]}"
  machine_type           = var.machine_type
  can_ip_forward         = true
  tags                   = ["fgt"]

  boot_disk {
    initialize_params {
      image              = data.google_compute_image.fgt_image.self_link
    }
  }
  attached_disk {
    source               = google_compute_disk.logdisk[count.index].name
  }

  service_account {
    email                = (var.service_account != "" ? var.service_account : data.google_compute_default_service_account.default.email)
    scopes               = ["cloud-platform"]
  }

  metadata = {
    user-data            = (count.index == 0 ? local.config_active : local.config_passive )
    license              = fileexists(var.license_files[count.index]) ? file(var.license_files[count.index]) : null
  }

  network_interface {
    subnetwork           = var.subnets["external"].id
    network_ip           = google_compute_address.ext_priv[count.index].address
  }
  network_interface {
    subnetwork           = var.subnets["internal"].id
    network_ip           = google_compute_address.int_priv[count.index].address
  }
  network_interface {
    subnetwork           = var.subnets["hasync"].id
    network_ip           = google_compute_address.hasync_priv[count.index].address
  }
  network_interface {
    subnetwork           = var.subnets["mgmt"].id
    network_ip           = google_compute_address.mgmt_priv[count.index].address
    access_config {
      nat_ip             = google_compute_address.mgmt_pub[count.index].address
    }
  }
  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"]
    ]
  }
} //fgt-vm


# Common Load Balancer resources
resource "google_compute_region_health_check" "health_check" {
  project                = var.project
  name                   = "${var.prefix}healthcheck-http${var.healthcheck_port}-${local.region_short}"
  region                 = var.region
  timeout_sec            = 2
  check_interval_sec     = 2

  http_health_check {
    port                 = var.healthcheck_port
  }
}

resource "google_compute_instance_group" "fgt-umigs" {
  count                  = 2
  project                = var.project
  name                   = "${var.prefix}umig${count.index}-${local.zones_short[count.index]}"
  zone                   = google_compute_instance.fgt-vm[count.index].zone
  instances              = [google_compute_instance.fgt-vm[count.index].self_link]
}

# Resources building Internal Load Balancer
resource "google_compute_region_backend_service" "ilb_bes" {
  provider               = google-beta
  project                = var.project
  name                   = "${var.prefix}bes-ilb-trust-${local.region_short}"
  region                 = var.region
  network                = var.subnets["internal"].network

  backend {
    group                = google_compute_instance_group.fgt-umigs[0].self_link
    balancing_mode       = "CONNECTION"
  }
  backend {
    group                = google_compute_instance_group.fgt-umigs[1].self_link
    balancing_mode       = "CONNECTION" 
  }

  health_checks          = [google_compute_region_health_check.health_check.self_link]
  connection_tracking_policy {
    connection_persistence_on_unhealthy_backends = "NEVER_PERSIST"
  }
}

resource "google_compute_forwarding_rule" "ilb_fwd_rule" {
  project                = var.project
  name                   = "${var.prefix}fwdrule-ilb-trust-${local.region_short}"
  region                 = var.region
  network                = var.subnets["internal"].network
  subnetwork             = var.subnets["internal"].id
  ip_address             = google_compute_address.ilb.address
  all_ports              = true
  load_balancing_scheme  = "INTERNAL"
  backend_service        = google_compute_region_backend_service.ilb_bes.self_link
  allow_global_access    = true
}

# Firewall rules
resource "google_compute_firewall" "allow-mgmt" {
  project                = var.project
  name                   = "${var.prefix}fw-mgmt-allow-admin"
  network                = var.subnets["mgmt"].network
  source_ranges          = ["0.0.0.0/0"]
  target_tags            = ["fgt"]

  allow {
    protocol             = "all"
  }
}

resource "google_compute_firewall" "allow-hasync" {
  project                = var.project
  name                   = "${var.prefix}fw-hasync-allow-fgt"
  network                = var.subnets["hasync"].network
  source_tags            = ["fgt"]
  target_tags            = ["fgt"]

  allow {
    protocol             = "all"
  }
}

resource "google_compute_firewall" "allow-port1" {
  project                = var.project
  name                   = "${var.prefix}fw-untrust-allowall"
  network                = var.subnets["external"].network
  source_ranges          = ["0.0.0.0/0"]

  allow {
    protocol             = "all"
  }
}

resource "google_compute_firewall" "allow-port2" {
  project                = var.project
  name                   = "${var.prefix}fw-trust-allowall"
  network                = var.subnets["internal"].network
  source_ranges          = ["0.0.0.0/0"]

  allow {
    protocol             = "all"
  }
}

# Enable outbound connectivity via Cloud NAT
resource "google_compute_router" "nat_router" {
  project                = var.project
  name                   = "${var.prefix}cr-cloudnat-${local.region_short}"
  region                 = var.region
  network                = var.subnets["external"].network
}

resource "google_compute_router_nat" "cloud_nat" {
  project                   = var.project
  name                      = "${var.prefix}nat-cloudnat-${local.region_short}"
  router                    = google_compute_router.nat_router.name
  region                    = var.region
  nat_ip_allocate_option    = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = var.subnets["external"].self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
