resource "azurerm_linux_virtual_machine" "main" {
  name                  = local.vm_name
  location              = azurerm_resource_group.main.location
  resource_group_name   = local.vm_resource_group_name
  admin_username        = var.admin_username
  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.main.id]
  secure_boot_enabled   = var.secure_boot_enabled
  vtpm_enabled          = var.vtpm_enabled
  tags                  = local.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = local.ssh_public_key
  }

  identity {
    type = "SystemAssigned"
  }

  additional_capabilities {
    hibernation_enabled = false
    ultra_ssd_enabled   = false
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  lifecycle {
    ignore_changes = [
      admin_ssh_key,
    ]
  }
}

resource "azurerm_virtual_machine_extension" "aad_ssh_login" {
  count = var.enable_aad_ssh_login ? 1 : 0

  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.main.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = local.tags
}

resource "azurerm_virtual_machine_extension" "vm_access" {
  count = var.enable_vm_access ? 1 : 0

  name                       = "enablevmAccess"
  virtual_machine_id         = azurerm_linux_virtual_machine.main.id
  publisher                  = "Microsoft.OSTCExtensions"
  type                       = "VMAccessForLinux"
  type_handler_version       = "1.5"
  auto_upgrade_minor_version = true
  tags                       = local.tags
}

resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  count = var.enable_azure_monitor_agent ? 1 : 0

  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.main.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  tags                       = local.tags
}

resource "azurerm_monitor_data_collection_rule" "vm_insights" {
  count = var.enable_vm_insights_rule ? 1 : 0

  name                = local.data_collection_rule_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.dcr_resource_group_name
  tags                = local.tags

  data_flow {
    destinations = [local.log_analytics_workspace_name]
    streams      = ["Microsoft-InsightsMetrics"]
  }

  data_sources {
    performance_counter {
      name                          = "Microsoft-InsightsMetrics"
      streams                       = ["Microsoft-InsightsMetrics"]
      counter_specifiers            = ["\\VmInsights\\DetailedMetrics"]
      sampling_frequency_in_seconds = 60
    }
  }

  destinations {
    log_analytics {
      name                  = local.log_analytics_workspace_name
      workspace_resource_id = var.log_analytics_workspace_resource_id
    }
  }

  lifecycle {
    precondition {
      condition     = var.log_analytics_workspace_resource_id != null
      error_message = "log_analytics_workspace_resource_id is required when enable_vm_insights_rule is true."
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "vm_insights" {
  count = var.enable_vm_insights_rule ? 1 : 0

  name                    = "${local.data_collection_rule_name}-association"
  target_resource_id      = azurerm_linux_virtual_machine.main.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.vm_insights[0].id
}
