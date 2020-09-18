variable global_settings {}
variable vm_dc1 {}
variable vm_dcn {}

variable admin_username {
  type        = string
  description = "Local Administrator account username"
  default     = "ladmin"
}
variable admin_password {
  type        = string
  description = "Local Administrator account password"
}
variable safe_mode_administrator_password {
    type = string
    description = "Active Directory safe mode administrator password"
}
variable ad_forest_name {
    type = string
    default = "corp.contoso.com"
}