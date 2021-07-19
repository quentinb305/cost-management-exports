resource "azurerm_resource_group" "rg" {
  name     = "__rg_name__"
  location = "__rg_location__"

  tags = {
    ProjectOwner = "__rg_tag_value__"
  }
}