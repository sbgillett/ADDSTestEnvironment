

prefix      = "sbg"
location    = "northeurope"
environment = "dev"
tags = {
  "Owner" = "Sam.Buccieri-Gillett@uk.clara.net"
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

pdc_private_ip_address = "10.0.50.5"
allow_rdp_from         = "81.174.137.251"
