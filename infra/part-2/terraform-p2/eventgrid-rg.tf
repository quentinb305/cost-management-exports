resource "azurerm_eventgrid_system_topic" "egt_rg" {
  name                   = "__egt_rg_name__"
  location               = "Global"
  resource_group_name    = azurerm_resource_group.rg.name
  source_arm_resource_id = "/subscriptions/__subscription_id__"
  topic_type             = "Microsoft.Resources.Subscriptions"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "egs_rg_fa" {
  name                = "__egs_rg_fa_name__"
  system_topic        = azurerm_eventgrid_system_topic.egt_rg.name
  resource_group_name = azurerm_resource_group.rg.name

  azure_function_endpoint {
    function_id = "${azurerm_function_app.fa_ce.id}/functions/EventGridTrigger1"
  }

  included_event_types = ["Microsoft.Resources.ResourceWriteSuccess"]

  advanced_filter {
    string_contains {
      key    = "data.authorization.action"
      values = ["Microsoft.Resources/subscriptions/resourceGroups/write"]
    }
    string_contains {
      key    = "data.resourceProvider"
      values = ["Microsoft.Resources"]
    }
    string_contains {
      key    = "data.operationName"
      values = ["Microsoft.Resources/subscriptions/resourceGroups/write"]
    }
    string_contains {
      key    = "data.status"
      values = ["Succeeded"]
    }
  }

  depends_on = [
    azurerm_function_app.fa_ce
  ]
}