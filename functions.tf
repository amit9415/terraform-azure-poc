resource "azurerm_resource_group" "fun-grp" {
  name     = "fun-grp-nov6-v1"
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

  depends_on = [ azurerm_service_plan.fun-serv-plan , azurerm_storage_account.fun-str-acc ]

  https_only                  = true

   app_settings = {
    "ENABLE_ORYX_BUILD"              = "true"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "FUNCTIONS_WORKER_RUNTIME"       = "python"
    "AzureWebJobsFeatureFlags"       = "EnableWorkerIndexing"
//    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.application_insight.instrumentation_key
  }

  site_config {
     application_stack {      
      python_version = "3.11"
    }
  }

}

resource "azurerm_storage_container" "mail-sender-code-container" {
  name                  = "mail-sender-code"
  storage_account_name  = azurerm_storage_account.fun-str-acc.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "mail-sender-code" {
  name                   = "mail_sender_code.zip"
  storage_account_name   =  azurerm_storage_account.fun-str-acc.name
  storage_container_name = azurerm_storage_container.mail-sender-code-container.name
  type                   = "Block"
  source                 = "/SendMailFunction/mail_sender_code.zip"
}