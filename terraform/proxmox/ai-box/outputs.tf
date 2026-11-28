locals {
  vm_ip = split("/", var.ipv4_cidr)[0]
}

output "vm_id" {
  value       = proxmox_virtual_environment_vm.main.vm_id
  description = "Proxmox VM ID of the AI box."
}

output "vm_ip" {
  value       = local.vm_ip
  description = "Static IPv4 address of the AI box."
}

output "ssh_command" {
  value       = "ssh -i ${var.private_key_path} ${var.admin_username}@${local.vm_ip}"
  description = "SSH command to connect to the AI box."
}

output "ollama_url" {
  value       = "http://${local.vm_ip}:11434"
  description = "Ollama API URL once Ollama is installed and listening on the LAN."
}
