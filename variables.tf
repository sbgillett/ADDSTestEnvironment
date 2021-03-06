variable "location" {
  type = string
}

variable "prefix" {
  type    = string
  default = null
}

variable "suffix" {
  type    = string
  default = null
}

variable "environment" {
  type = string
}

variable "tags" {
  default = null
}

variable convention {
  default = "cafrandom"

  validation {
    condition     = contains(["cafrandom", "random", "passthrough", "cafclassic"], var.convention)
    error_message = "Convention allowed values are cafrandom, random, passthrough or cafclassic."
  }
}

variable resource_groups {}

variable networking {}

variable subnets {}

variable vm {}
variable vm_domain_members {}

variable admin_username {
  type        = string
  description = "Local Administrator account username"
  default     = "ladmin"
}
variable admin_password {
  type        = string
  description = "Local Administrator account password"
}

variable allow_rdp_from {
  type        = string
  default     = null
  description = "Allow RDP connections to the core vnet from these IPv4 addresses"
}

variable safe_mode_administrator_password {
  type        = string
  description = "Active Directory safe mode administrator password"
}
variable ad_forest_name {
  type    = string
  default = "corp.contoso.com"
}