/*
  This unit will be used to create a Shared VPC for the target workloads.
  We should move all VMs to this shared VPC to put it under Fortigate config.
*/
include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  prefix = "gcp-fortigate-"
}

terraform {
  source = "${path_relative_from_include()}/../../modules/shared-vpc"
}

inputs = {
  prefix          = local.prefix
  host_project    = "${include.root.inputs.spoke_project}"
  service_project = "${include.root.inputs.service_project}"
  shared_subnets  = {
    "vm1" = "10.10.0.0/28",
    "vm2" = "10.10.0.16/28"
  }
}
