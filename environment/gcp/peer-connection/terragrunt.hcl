/*
  This unit will be used to create a peering between the internal VPC on Fortigate Hub project and the Shared VPC on spoke project.
*/
include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  prefix = "gcp-fortigate-"
}

terraform {
  source = "${path_relative_from_include()}/../../modules/peer-connection"
}

dependency "network" {
  config_path  = "../network"
  mock_outputs = {
    vpcs = {
      internal = {
        name      = "fortigate-internal-network"
        self_link = "projects/test/global/networks/fortigate-internal-network"
      }
    }
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

dependency "sharedvpc" {
  config_path  = "../sharedvpc"
  mock_outputs = {
    shared_vpc = {
      name      = "fortigate-network"
      self_link = "projects/test/global/networks/fortigate-network"
    }
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

inputs = {
  prefix                           = local.prefix

  fortigate_hub_project            = "${include.root.inputs.hub_project}"
  fortigate_internal_vpc_self_link = "${dependency.network.outputs.vpcs["internal"].self_link}"

  shared_vpc_project               = "${include.root.inputs.spoke_project}"
  shared_vpc_name                  = "${dependency.sharedvpc.outputs.shared_vpc.name}"
  shared_vpc_self_link             = "${dependency.sharedvpc.outputs.shared_vpc.self_link}"
}
