# Ref: https://cloud.google.com/architecture/partners/use-terraform-to-deploy-a-fortigate-ngfw#create_a_custom_role_and_a_service_account
resource "google_project_iam_custom_role" "fortigate" {
  role_id     = "fortigate"
  project     = var.project
  title       = "Fortigate SDN Connector Role (read-only)"
  description = "Custom Role for Fortigate deployment"
  permissions = [
    "compute.zones.list",
    "compute.instances.list",
    "container.clusters.list",
    "container.nodes.list",
    "container.pods.list",
    "container.services.list"
  ]
}

resource "google_service_account" "fortigate" {
  project      = var.project
  account_id   = "fortigate"
  display_name = "fortigate"
  description  = "Service Account used to deploy fortigate"
}

resource "google_service_account_iam_member" "fortigate_custom_role" {
  service_account_id = google_service_account.fortigate.name
  role               = google_project_iam_custom_role.fortigate.name
  member             = google_service_account.fortigate.member
}
