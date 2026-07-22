locals {
  resource_group_name          = coalesce(var.resource_group_name, "${var.service_name}-${var.environment}-rg")
  vm_resource_group_name       = coalesce(var.vm_resource_group_name, local.resource_group_name)
  virtual_network_name         = coalesce(var.virtual_network_name, "${var.service_name}-${var.environment}-vnet")
  network_security_group_name  = coalesce(var.network_security_group_name, "${var.service_name}-${var.environment}-nsg")
  network_interface_name       = coalesce(var.network_interface_name, "${var.service_name}-${var.environment}-nic")
  public_ip_name               = coalesce(var.public_ip_name, "${var.service_name}-${var.environment}-pip")
  ssh_key_name                 = coalesce(var.ssh_key_name, "${var.service_name}-${var.environment}-ssh-key")
  vm_name                      = coalesce(var.vm_name, "${var.service_name}-${var.environment}-vm")
  data_collection_rule_name    = coalesce(var.data_collection_rule_name, "MSVMI-${var.location}-${var.service_name}")
  dcr_resource_group_name      = coalesce(var.data_collection_rule_resource_group_name, local.vm_resource_group_name)
  log_analytics_workspace_name = "vmInsightworkspace"
  ssh_public_key               = file(pathexpand(var.public_key_path))

  tags = {
    Environment = var.environment
    Service     = var.service_name
  }
}
