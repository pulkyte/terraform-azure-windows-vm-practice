output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "nic_ids" {
  value = azurerm_network_interface.nic[*].id
}

output "public_ips" {
  value = azurerm_public_ip.pip[*].ip_address
}