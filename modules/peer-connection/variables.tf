variable prefix {
  type = string
  description = "Prefix to be added to all created resources"
}

variable fortigate_hub_project {
  description = "Name of the FortiGate hub project"
  type        = string
}

variable "fortigate_internal_vpc_self_link" {
  type        = string
  description = "The VPC A used on the peering config."
  default     = null
}

variable "shared_vpc_name" {
  type        = string
  description = "Name of the VPC to be peered with FortiGate hub."
}

variable "shared_vpc_project" {
  type        = string
  description = "Name of the project hosting the spoke VPC to be peered with FortiGate hub."
}

variable "shared_vpc_self_link" {
  type        = string
  description = "The VPC B used on the peering config."
  default     = null
}
