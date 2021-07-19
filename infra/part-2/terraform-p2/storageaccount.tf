resource "azurerm_storage_account" "sa_acm_reports" {
  name                     = "__sa_acm_reports_name__"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sa_ctn_acm_reports" {
  name                  = "__sa_ctn_acm_reports_name__"
  storage_account_name  = azurerm_storage_account.sa_acm_reports.name
  container_access_type = "private"
}