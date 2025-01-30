/*
  This unit will be used to create all resources for the Fortigate Deployment.
  It will deploy:
   - VMs for Fortigate
   - Load Balancers
   - IP addresses used by VMs
   - Cloud Router and Cloud NAT
*/
include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  prefix = "gcp-fortigate-"
}

terraform {
  source = "${path_relative_from_include()}/../../modules/fortigate-application"
}

dependency "networks" {
  config_path = "../network"
  mock_outputs = {
   subnets = {
    external = {
      id = 1
      name = "subnet-1"
      self_link = "subnet-1"
      network = "fortigate-network"
      gateway_address = "127.0.0.1"
      ip_cidr_range = "127.0.0.1/32"
    },
    internal = {
      id = 2
      name = "subnet-2"
      self_link = "subnet-1"
      network = "fortigate-network"
      gateway_address = "127.0.0.1"
      ip_cidr_range = "127.0.0.1/32"
    },
    hasync   = {
      id = 3
      name = "subnet-3"
      self_link = "subnet-1"
      network = "fortigate-network"
      gateway_address = "127.0.0.1"
      ip_cidr_range = "127.0.0.1/32"
    },
    mgmt     = {
      id = 4
      name = "subnet-4"
      self_link = "subnet-1"
      network = "fortigate-network"
      gateway_address = "127.0.0.1"
      ip_cidr_range = "127.0.0.1/32"
    }
   }
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

inputs = {
  prefix  = local.prefix
  region  = "${include.root.inputs.region}"
  project = "${include.root.inputs.hub_project}"
  subnets = "${dependency.networks.outputs.subnets}"
}
