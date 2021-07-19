resource "azurerm_template_deployment" "api_office" {
  name                = "__api_office_name__"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"
  template_body       = file("../arm-p2/api-o365.json")
  parameters = {
    "connections_office365_name" = "office365"
    "o365_api_id"                = "/subscriptions/__subscription_id__/providers/Microsoft.Web/locations/${azurerm_resource_group.rg.location}/managedApis/office365"
    "location"                   = azurerm_resource_group.rg.location
  }
}
