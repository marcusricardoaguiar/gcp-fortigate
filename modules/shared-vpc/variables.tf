variable prefix {
  type = string
  description = "Prefix to be added to all created resources"
}

variable host_project {
  description = "GCP Host Project for the shared VPC"
  type        = string
}

variable service_project {
  description = "GCP Service Project for the shared VPC"
  type        = string
}

variable shared_subnets {
  type        = map
  description = "The subnets that should be created on the shared VPC"
}
