resource "azurerm_resource_group" "fun-grp" {
  name     = "fun-grp-aus"
  location = "Australia Central"
}

resource "azurerm_storage_account" "fun-str-acc" {
  name                     = "funstraccpoc123123123"
  resource_group_name      = azurerm_resource_group.fun-grp.name
  location                 = azurerm_resource_group.fun-grp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "fun-serv-plan" {
  name                = "funservplan1234"
  resource_group_name = azurerm_resource_group.fun-grp.name
  location            = azurerm_resource_group.fun-grp.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_function_app" "fun-app" {
  name                = "funapp123123"
  resource_group_name = azurerm_resource_group.fun-grp.name
  location            = azurerm_resource_group.fun-grp.location

  storage_account_name       = azurerm_storage_account.fun-str-acc.name
  storage_account_access_key = azurerm_storage_account.fun-str-acc.primary_access_key
  service_plan_id            = azurerm_service_plan.fun-serv-plan.id

  site_config {}
}