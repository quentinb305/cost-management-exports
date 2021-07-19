resource "azurerm_template_deployment" "logicapp_batchreceiver" {
  name                = "__logicapp_batchreceiver_name__"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"
  template_body       = file("../arm-p2/logicapp-batchreceiver.json")
  parameters = {
    "workflows_logicapp_receiver_name" = "__logicapp_batchreceiver_name__"
    "connections_azureblob_externalid" = "/subscriptions/__subscription_id__/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Web/connections/azureblob"
    "connections_office365_externalid" = "/subscriptions/__subscription_id__/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Web/connections/office365"
    "sites_function_externalid"        = "/subscriptions/__subscription_id__/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Web/sites/${azurerm_function_app.fa_gpot.name}/functions/HttpTrigger1"
    "blob_api_id"                      = "/subscriptions/__subscription_id__/providers/Microsoft.Web/locations/${azurerm_resource_group.rg.location}/managedApis/azureblob"
    "o365_api_id"                      = "/subscriptions/__subscription_id__/providers/Microsoft.Web/locations/${azurerm_resource_group.rg.location}/managedApis/office365"
    "location"                         = azurerm_resource_group.rg.location
    "cc_verification_email"            = "__cc_verification_email__"
  }
  depends_on = [
    azurerm_template_deployment.api_blob,
    azurerm_template_deployment.api_office,
    azurerm_function_app.fa_gpot
  ]
}

resource "azurerm_template_deployment" "logicapp_batchsender" {
  name                = "__logicapp_batchsender_name__"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"
  template_body       = file("../arm-p2/logicapp-batchsender.json")
  parameters = {
    "workflows_logicapp_name"               = "__logicapp_batchsender_name__"
    "connections_azureeventgrid_externalid" = "/subscriptions/__subscription_id__/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Web/connections/azureeventgrid"
    "eventgrid_api_id"                      = "/subscriptions/__subscription_id__/providers/Microsoft.Web/locations/${azurerm_resource_group.rg.location}/managedApis/azureeventgrid"
    "location"                              = azurerm_resource_group.rg.location
    "storage_id"                            = azurerm_storage_account.sa_acm_reports.id
    "workflows_logicapp_receiver_id"        = "/subscriptions/__subscription_id__/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Logic/workflows/__logicapp_batchreceiver_name__"
    "subscription_id"                       = "__subscription_id__"
    "egs_blob_wh_name"                      = "__egs_blob_wh_name__"
  }

  depends_on = [
    azurerm_template_deployment.logicapp_batchreceiver,
    azurerm_template_deployment.api_eventgrid,
    azurerm_storage_account.sa_acm_reports
  ]
}
