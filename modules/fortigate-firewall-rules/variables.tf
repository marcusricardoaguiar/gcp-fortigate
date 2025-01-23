variable prefix {
  type        = string
  default     = "fgt"
  description = "This prefix will be added to all created resources"
}

variable "fortigate_elb_eip_address" {
  type        = string
  description = "The Fortigate External LB IP address"
}

variable targets {
  type = list(object({
    name = string
    ip = string
    port = number
    mappedport = number
  }))
  description = "This prefix will be added to all created resources"
}
