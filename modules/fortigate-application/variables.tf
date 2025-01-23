variable "project" {
  description = "GCP Project ID"
  type        = string
  default     = ""
}

variable region {
  type        = string
  default     = "europe-west1"
  description = "Region to deploy all resources in. Must match var.zones if defined."
}

variable prefix {
  type        = string
  default     = "fgt"
  description = "This prefix will be added to all created resources"
}

variable zones {
  type        = list(string)
  default     = ["",""]
  description = "Names of zones to deploy FortiGate instances to matching the region variable. Defaults to first 2 zones in given region."
}

variable subnets {
  type        = object({
    external = object({
      gateway_address    = string
      id                 = string
      ip_cidr_range      = string
      network            = string
      name               = string
      self_link          = string
      project            = optional(string)
      subnetwork_id      = optional(string)
    }),
    internal = object({
      gateway_address    = string
      id                 = string
      ip_cidr_range      = string
      network            = string
      name               = string
      self_link          = string
      project            = optional(string)
      subnetwork_id      = optional(string)
    }),
    hasync = object({
      gateway_address    = string
      id                 = string
      ip_cidr_range      = string
      network            = string
      name               = string
      self_link          = string
      project            = optional(string)
      subnetwork_id      = optional(string)
    }),
    mgmt = object({
      gateway_address    = string
      id                 = string
      ip_cidr_range      = string
      network            = string
      name               = string
      self_link          = string
      project            = optional(string)
      subnetwork_id      = optional(string)
    })
  })
  description = "Names of four existing subnets to be connected to FortiGate VMs (external, internal, heartbeat, management)"
}

variable machine_type {
  type        = string
  default     = "e2-standard-4"
  description = "GCE machine type to use for VMs. Minimum 4 vCPUs are needed for 4 NICs"
}

variable service_account {
  type        = string
  default     = ""
  description = "E-mail of service account to be assigned to FortiGate VMs. Defaults to Default Compute Engine Account"
}

variable license_files {
  type        = list(string)
  default     = ["NONE","NONE"]
  description = "List of license (.lic) files to be applied for BYOL instances."
}

variable healthcheck_port {
  type        = number
  default     = 8008
  description = "Port used for LB health checks"
}
