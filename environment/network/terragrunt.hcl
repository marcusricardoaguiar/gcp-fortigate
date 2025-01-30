/*
  This unit will be used to create all networks and subnetworks used by Fortigate Deployment.
*/
include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  prefix = "gcp-fortigate-"
}

terraform {
  source = "${path_relative_from_include()}/../../modules/fortigate-network"
}

inputs = {
  prefix   = local.prefix
  region   = "${include.root.inputs.region}"
  project  = "${include.root.inputs.hub_project}"
  networks = ["external", "internal", "hasync", "mgmt"]
}
