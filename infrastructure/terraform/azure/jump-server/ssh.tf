resource "azurerm_ssh_public_key" "main" {
  name                = local.ssh_key_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  public_key          = local.ssh_public_key
  tags                = local.tags
}
