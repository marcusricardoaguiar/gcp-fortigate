include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  prefix = "gcp-fortigate-"
}

terraform {
  source = "${path_relative_from_include()}/../modules/fortigate-firewall-rules"
}

dependency "application" {
  config_path = "../application"
  mock_outputs = {
   elb_ip_address = "127.0.0.1"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

inputs = {
  prefix                    = local.prefix
  fortigate_elb_eip_address = "${dependency.application.outputs.elb_ip_address}"

  targets = [{
    name       = "vm1"
    ip         = "10.10.0.18",
    port       = 80,
    mappedport = 8080
  }]
}
