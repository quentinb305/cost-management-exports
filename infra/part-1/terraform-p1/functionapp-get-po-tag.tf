resource "azurerm_application_insights" "ai_fa_gpot" {
  name                = "__ai_fa_gpot_name__"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

resource "azurerm_storage_account" "sa_fa_gpot" {
  name                     = "__sa_fa_gpot_name__"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "sa_fs_fa_gpot" {
  name                 = "__sa_fs_fa_gpot_name__"
  storage_account_name = azurerm_storage_account.sa_fa_ce.name
}

resource "azurerm_app_service_plan" "asp_fa_gpot" {
  name                = "__asp_fa_gpot_name__"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "fa_gpot" {
  name                       = "__fa_gpot_name__"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  app_service_plan_id        = azurerm_app_service_plan.asp_fa_gpot.id
  storage_account_name       = azurerm_storage_account.sa_fa_gpot.name
  storage_account_access_key = azurerm_storage_account.sa_fa_gpot.primary_access_key
  version                    = "~3"
  tags = {
    ProjectOwner = "__rg_tag_value__"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME                 = "node"
    WEBSITE_NODE_DEFAULT_VERSION             = "10.14.1"
    WEBSITE_CONTENTSHARE                     = "${azurerm_storage_share.sa_fs_fa_gpot.name}"
    APPINSIGHTS_INSTRUMENTATIONKEY           = "${azurerm_application_insights.ai_fa_gpot.instrumentation_key}"
    AzureWebJobsDashboard                    = "${azurerm_storage_account.sa_fa_gpot.primary_connection_string}"
    AzureWebJobsStorage                      = "${azurerm_storage_account.sa_fa_gpot.primary_connection_string}"
    FUNCTIONS_EXTENSION_VERSION              = "~3"
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = "${azurerm_storage_account.sa_fa_gpot.primary_connection_string}"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE          = "true"
    WEBSITE_RUN_FROM_PACKAGE                 = "1"
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "fa_gpot_id_reader_role" {
  scope                = "/subscriptions/__subscription_id__"
  role_definition_name = "Reader"
  principal_id         = azurerm_function_app.fa_gpot.identity.0.principal_id
}