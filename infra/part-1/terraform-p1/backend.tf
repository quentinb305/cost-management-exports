terraform {
  backend "azurerm" {
    resource_group_name  = "__rg_tf_state_name__"
    storage_account_name = "__sa_tf_state_name__"
    container_name       = "__sa_ctn_tf_state_name__"
    key                  = "__key_tf_state_name__"
  }
}