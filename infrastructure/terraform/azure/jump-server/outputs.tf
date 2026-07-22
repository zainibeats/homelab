output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Name of the Azure resource group."
}

output "vm_id" {
  value       = azurerm_linux_virtual_machine.main.id
  description = "ID of the Linux virtual machine."
}

output "public_ip" {
  value       = azurerm_public_ip.main.ip_address
  description = "Public IPv4 address assigned to the Linux virtual machine."
}

output "ssh_command" {
  value       = "ssh -i ${var.private_key_path} ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
  description = "SSH command to connect to the Linux virtual machine."
}
