

prefix      = "sbg"
location    = "northeurope"
environment = "dev"
tags = {
  "Owner" = "someone@example.com"
}

resource_groups = {
  core = {
    name       = "core"
    usesuffix  = true
    useprefix  = true
    max_length = 40
  }
}

networking = {
  core = {
    name               = "core"
    resource_group_key = "core"
    usesuffix          = true
    max_length         = 40
    address_space      = ["10.0.50.0/24"]
  }
}

subnets = {
  default = {
    name                = "default"
    virtual_network_key = "core"
    usesuffix           = true
    max_length          = 40
    address_prefixes    = ["10.0.50.0/24"]
  }
}

allow_rdp_from = "81.174.137.251"

vm = {
  dc1 = {
    name               = "DC1"
    resource_group_key = "core"
    size               = "Standard_B2ms"
    subnet_key         = "default"
    max_length = 40
    private_ip_address = "10.0.50.5"
  }

  //Other member domain controllers
  dcn = {
    name_prefix        = "DC"
    instance_count     = 1
    resource_group_key = "core"
    size               = "Standard_B2ms"
    subnet_key         = "default"
    max_length = 40
  }
}

safe_mode_administrator_password = "34RumblyTumbly"