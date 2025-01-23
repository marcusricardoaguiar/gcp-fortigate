resource "google_compute_address" "mgmt_pub" {
  count                  = 2
  region                 = var.region
  project                = var.project
  name                   = "${var.prefix}eip${count.index+1}-mgmt-${local.region_short}"
}

resource "google_compute_address" "ext_priv" {
  count                  = 2
  name                   = "${var.prefix}ip${count.index+1}-untrust-${local.region_short}"
  region                 = var.region
  project                = var.project
  address_type           = "INTERNAL"
  subnetwork             = var.subnets["external"].id
}

resource "google_compute_address" "int_priv" {
  count                  = 2
  name                   = "${var.prefix}ip${count.index+1}-trust-${local.region_short}"
  region                 = var.region
  project                = var.project
  address_type           = "INTERNAL"
  subnetwork             = var.subnets["internal"].id
}

resource "google_compute_address" "ilb" {
  name                   = "${var.prefix}ip-ilb-trust-${local.region_short}"
  region                 = var.region
  project                = var.project
  address_type           = "INTERNAL"
  subnetwork             = var.subnets["internal"].id
}

resource "google_compute_address" "hasync_priv" {
  count                  = 2
  name                   = "${var.prefix}ip${count.index+1}-hasync-${local.region_short}"
  region                 = var.region
  project                = var.project
  address_type           = "INTERNAL"
  subnetwork             = var.subnets["hasync"].id
}

resource "google_compute_address" "mgmt_priv" {
  count                  = 2
  name                   = "${var.prefix}ip${count.index+1}-mgmt-${local.region_short}"
  region                 = var.region
  project                = var.project
  address_type           = "INTERNAL"
  subnetwork             = var.subnets["mgmt"].id
}
