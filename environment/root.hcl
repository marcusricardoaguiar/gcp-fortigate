# Configure the remote backend
remote_state {
  backend = "local"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    path= "./terraform.tfstate"
  }
}

locals {
  project_id         = "host-fortigate"
  region             = "us-central1"
  service_project_id = "service-fortigate"
  hub_project_id     = "host-fortigate"
  spoke_project_id   = "service-fortigate"

  fortigate_hostname = "placeholder"
  fortigate_api_key  = "placeholder"
}

inputs = {
  region          = local.region
  service_project = local.service_project_id
  hub_project     = local.hub_project_id
  spoke_project   = local.spoke_project_id
}

# Configure the GCP provider
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "google" {
  credentials = file("${find_in_parent_folders("fine-physics-449114-t4-0c86290f3844.json")}")
  project     = "${local.service_project}"
  region      = "${local.region}"
}
provider "google-beta" {
  credentials = file("${find_in_parent_folders("fine-physics-449114-t4-0c86290f3844.json")}")
  project     = "${local.service_project}"
  region      = "${local.region}"
}
EOF
}

# Configure the GCP provider
generate "fortios-provider" {
  path      = "provider-fortios.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "fortios" {
  hostname  = "${local.fortigate_hostname}"
  token     = "${local.fortigate_api_key}"
  insecure  = "true"
}
EOF
}
