resource "azurerm_template_deployment" "api_eventgrid" {
  name                = "__api_eventgrid_name__"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"
  template_body       = file("../arm-p2/api-eventgrid.json")
  parameters = {
    "connections_eventgrid_name" = "azureeventgrid"
    "eventgrid_api_id"           = "/subscriptions/__subscription_id__/providers/Microsoft.Web/locations/${azurerm_resource_group.rg.location}/managedApis/azureeventgrid"
    "location"                   = azurerm_resource_group.rg.location
  }
}
