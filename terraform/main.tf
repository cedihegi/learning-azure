data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "${var.resource_group_name}-${var.environment_short}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "cedihegi-${var.environment_short}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "pdns" {
  name                = "private_dns_${var.environment_short}.azure-devices.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_dns_link" {
    name = "vnet-dns-link"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.pdns.name
    virtual_network_id = azurerm_virtual_network.vnet.id
    registration_enabled = true
}

resource "azurerm_subnet" "subnet" {
  name                 = "cedihegi-${var.environment_short}-subnet"
  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

resource "azurerm_public_ip" "ip" {
  name                = "edge-vm-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "edge-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "edge-vm-ip-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }
}

data "template_cloudinit_config" "edgehost_cloudinit_config" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.edgehost_cloudinit_file.rendered
  }
}

data "template_file" "edgehost_cloudinit_file" {
  template = file("resources/cloud-init.yml")
  // The vars are replaced with the Varialbes marked as ${...} in the template file
  vars = {
    # todo: properly set up things so we can pass in these variables
    # "dcs" = var.input_edge_connectionstring
    # "certfilename" = var.input_edge_cert_filename
  }
}

resource "azurerm_linux_virtual_machine" "egehost_vm" {
  name                            = "edgehost-${var.environment_short}-vm"
  location                        = var.resource_group_location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = "Standard_B2s"
  computer_name                   = "edgepc"
  admin_username                  = "localadmin"
  admin_password                  = "Hello_there2"
  disable_password_authentication = false
  custom_data                     = data.template_cloudinit_config.edgehost_cloudinit_config.rendered
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
