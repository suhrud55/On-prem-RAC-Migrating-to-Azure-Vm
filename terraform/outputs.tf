output "primary_vm_private_ip" {
  value       = azurerm_network_interface.nic1.private_ip_address
  description = "Private IP of primary Oracle VM"
}

output "standby_vm_private_ip" {
  value       = azurerm_network_interface.nic2.private_ip_address
  description = "Private IP of standby Oracle VM"
}
