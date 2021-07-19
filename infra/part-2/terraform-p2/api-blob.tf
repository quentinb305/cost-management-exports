resource "azurerm_template_deployment" "api_blob" {
  name                = "__api_blob_name__"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"
  template_body       = file("../arm-p2/api-blob.json")
  parameters = {
    "connections_azureblob_name" = "azureblob"
    "blob_api_id"                = "/subscriptions/__subscription_id__/providers/Microsoft.Web/locations/${azurerm_resource_group.rg.location}/managedApis/azureblob"
    "location"                   = azurerm_resource_group.rg.location
    "storage_name"               = azurerm_storage_account.sa_acm_reports.name
    "storage_access_key"         = azurerm_storage_account.sa_acm_reports.primary_access_key
  }
}
