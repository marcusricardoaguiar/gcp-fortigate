# DNS Zone for the FortiGate Management UI
resource "google_dns_managed_zone" "fortigate" {
  name          = "fortigate-ui"
  project       = var.project
  dns_name      = "fortigate.com."
  description   = "Fortigate UI"
  force_destroy = "true"
}

# Attach the FortiGate primary instance on the DNS zone
resource "google_dns_record_set" "fortigate" {
  name         = google_dns_managed_zone.fortigate.dns_name
  project      = var.project
  managed_zone = google_dns_managed_zone.fortigate.name
  type         = "A"
  ttl          = 300
  rrdatas = [
    google_compute_instance.fgt-vm[0].network_interface[3].access_config[0].nat_ip
  ]
}

# Attach the FortiGate primary instance on the DNS zone
resource "google_dns_record_set" "primary_fortigate" {
  name         = "primary.${google_dns_managed_zone.fortigate.dns_name}"
  project      = var.project
  managed_zone = google_dns_managed_zone.fortigate.name
  type         = "A"
  ttl          = 300
  rrdatas = [
    google_compute_instance.fgt-vm[0].network_interface[3].access_config[0].nat_ip
  ]
}

# Attach the FortiGate secondary instance on the DNS zone
resource "google_dns_record_set" "secondary_fortigate" {
  name         = "secondary.${google_dns_managed_zone.fortigate.dns_name}"
  project      = var.project
  managed_zone = google_dns_managed_zone.fortigate.name
  type         = "A"
  ttl          = 300
  rrdatas = [
    google_compute_instance.fgt-vm[1].network_interface[3].access_config[0].nat_ip
  ]
}
