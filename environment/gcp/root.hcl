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
  project_id         = "terraform-opa"
  region             = "us-central1"
  service_project_id = "terraform-opa"
  hub_project_id     = "terraform-opa"
  spoke_project_id   = "terraform-opa"

  fortigate_hostname     = "35.222.123.111"
  fortigate_api_key      = "asdfasdgsdfghsdfgsadfasdf"
}

inputs = {
  project         = local.service_project_id
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
  credentials = file("${find_in_parent_folders("terraform-opa-4e64c656583b.json")}")
  project     = "${local.project_id}"
  region      = "${local.region}"
}
provider "google-beta" {
  credentials = file("${find_in_parent_folders("terraform-opa-4e64c656583b.json")}")
  project     = "${local.project_id}"
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
