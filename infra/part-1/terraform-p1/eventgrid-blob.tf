resource "azurerm_eventgrid_system_topic" "egt_blob" {
  name                   = "__egt_blob_name__"
  location               = azurerm_resource_group.rg.location
  resource_group_name    = azurerm_resource_group.rg.name
  source_arm_resource_id = azurerm_storage_account.sa_acm_reports.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
}