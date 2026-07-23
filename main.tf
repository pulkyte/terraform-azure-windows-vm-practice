module "resource_group" {
  source = "./modules/resource-group"

  name     = var.resource_group_name
  location = var.location
}

module "networking" {
  source  = "./modules/networking"
  vm_name = var.vm_name
  vm_count = var.vm_count
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
}
resource "azurerm_windows_virtual_machine" "vm" {

  count = var.vm_count
  name = format("%s-%02d",var.vm_name,count.index+1)
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  size           = "Standard_B2ats_v2"

  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [
    module.networking.nic_ids[count.index]
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
  value = module.networking.public_ips
}

output "vm_name" {
  value = azurerm_windows_virtual_machine.vm[*].name
}