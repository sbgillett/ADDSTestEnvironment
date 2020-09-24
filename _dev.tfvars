prefix      = "sbg"
location    = "northeurope"
environment = "dev"
tags = {
  "Owner" = "someone@example.com"
}

resource_groups = {
  core = {
    name       = "core"
    location   = "northeurope"
    usesuffix  = true
    useprefix  = true
    max_length = 40
  }
  domain_members = {
    name       = "domain_members"
    location   = "northeurope"
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
    max_length         = 40
    private_ip_address = "10.0.50.5"
  }

  //Other member domain controllers
  dcn = {
    name_prefix        = "DC"
    instance_count     = 1 //Number of desired DCs
    resource_group_key = "core"
    size               = "Standard_B2ms"
    subnet_key         = "default"
    max_length         = 40
  }
}

//Domain members
vm_domain_members = {
  server_2008R2 = {
    name               = "server2008r2"
    max_length         = 40
    resource_group_key = "domain_members"
    subnet_key         = "default"
    size               = "Standard_B2ms"
    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "windowsserver"
      sku       = "2008-R2-SP1-smalldisk"
      version   = "latest"
    }
    activate_winrm = true
  }
  server_2012R2 = {
    name               = "server2012r2"
    max_length         = 40
    resource_group_key = "domain_members"
    subnet_key         = "default"
    size               = "Standard_B2ms"
    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "windowsserver"
      sku       = "2012-R2-Datacenter-smalldisk"
      version   = "latest"
    }
  }
  server_2016 = {
    name               = "server2016"
    max_length         = 40
    resource_group_key = "domain_members"
    subnet_key         = "default"
    size               = "Standard_B2ms"
    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "windowsserver"
      sku       = "2016-Datacenter-smalldisk"
      version   = "latest"
    }
  }
  server_2019 = {
    name               = "server2019"
    max_length         = 40
    resource_group_key = "domain_members"
    subnet_key         = "default"
    size               = "Standard_B2ms"
    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "windowsserver"
      sku       = "2019-Datacenter-smalldisk"
      version   = "latest"
    }
  }
  itmgmt = {
    name               = "itmgmt"
    max_length         = 40
    resource_group_key = "domain_members"
    subnet_key         = "default"
    size               = "Standard_B2ms"
    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "windowsserver"
      sku       = "2019-Datacenter-smalldisk"
      version   = "latest"
    }
  }
}
safe_mode_administrator_password = "34RumblyTumbly"

//Discover images with
//Get-AzVMImageSku -Location "northeurope" -PublisherName "MicrosoftWindowsServer" -Offer "windowsserver"