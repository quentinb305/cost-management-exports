resource "azurerm_application_insights" "ai_fa_ce" {
  name                = "__ai_fa_ce_name__"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

resource "azurerm_storage_account" "sa_fa_ce" {
  name                     = "__sa_fa_ce_name__"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "sa_fs_fa_ce" {
  name                 = "__sa_fs_fa_ce_name__"
  storage_account_name = azurerm_storage_account.sa_fa_ce.name
}

resource "azurerm_app_service_plan" "asp_fa_ce" {
  name                = "__asp_fa_ce_name__"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "fa_ce" {
  name                       = "__fa_ce_name__"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  app_service_plan_id        = azurerm_app_service_plan.asp_fa_ce.id
  storage_account_name       = azurerm_storage_account.sa_fa_ce.name
  storage_account_access_key = azurerm_storage_account.sa_fa_ce.primary_access_key
  version                    = "~3"
  tags = {
    ProjectOwner = "__rg_tag_value__"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME                 = "powershell"
    WEBSITE_CONTENTSHARE                     = "${azurerm_storage_share.sa_fs_fa_ce.name}"
    APPINSIGHTS_INSTRUMENTATIONKEY           = "${azurerm_application_insights.ai_fa_ce.instrumentation_key}"
    AzureWebJobsDashboard                    = "${azurerm_storage_account.sa_fa_ce.primary_connection_string}"
    AzureWebJobsStorage                      = "${azurerm_storage_account.sa_fa_ce.primary_connection_string}"
    FUNCTIONS_EXTENSION_VERSION              = "~3"
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = "${azurerm_storage_account.sa_fa_ce.primary_connection_string}"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE          = "true"
    WEBSITE_RUN_FROM_PACKAGE                 = "1"
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "fa_ce_id_acm_role" {
  scope                = "/subscriptions/__subscription_id__"
  role_definition_name = "Cost Management Contributor"
  principal_id         = azurerm_function_app.fa_ce.identity.0.principal_id
}

resource "azurerm_role_assignment" "fa_ce_id_reader_role" {
  scope                = "/subscriptions/__subscription_id__/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Storage/storageAccounts/${azurerm_storage_account.sa_acm_reports.name}"
  role_definition_name = "Reader"
  principal_id         = azurerm_function_app.fa_ce.identity.0.principal_id
  depends_on = [
    azurerm_storage_account.sa_acm_reports
  ]
}
