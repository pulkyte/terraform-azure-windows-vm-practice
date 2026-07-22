resource "azurerm_resource_group" "rg" {

  name     = var.resource_group_name

  location = var.location

}

resource "azurerm_virtual_network" "vnet" {
  name  = "${var.vm_name}-vnet"
  location =  azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name  = "default"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name  = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.0.0/24"]
}
resource "azurerm_public_ip" "pip" {
  name                = "${var.vm_name}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"
}
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"

    source_port_range          = "*"
    destination_port_range     = "3389"

    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"

    subnet_id                     = azurerm_subnet.subnet.id

    private_ip_address_allocation = "Dynamic"

    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
resource "azurerm_windows_virtual_machine" "vm" {

  name                = var.vm_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  size           = "Standard_B2ats_v2"

  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  boot_diagnostics {}
}
output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "vm_name" {
  value = azurerm_windows_virtual_machine.vm.name
}