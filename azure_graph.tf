/*
# Define a data block to fetch the object_id from the currently signed Azure AD account
data "azuread_client_config" "current" {}


resource "azuread_application" "app" {
  display_name     = "tf-app"
  sign_in_audience = "AzureADMultipleOrgs"
  owners           = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "email_sender_sp" {
  client_id = azuread_application.app.client_id
}

#Generate client secret
resource "azuread_application_password" "secret" {
   application_id    = azuread_application.app.id
}

resource "random_uuid" "email_sender_administrator" {}

resource "azuread_application_app_role" "email_sender_permission" { 
  role_id        = random_uuid.email_sender_administrator.id
  application_id = azuread_application.app.id
  allowed_member_types =  ["User", "Application"]
  description          = "Admins can manage roles and perform all task actions"
  display_name         = "Administer"
  value                = "admin"
} 

output "client_id" {
  value = azuread_application.app.client_id
}

output "client_secret" {
  value     = azuread_application_password.secret.value
  sensitive = true
}

*/
resource "azurerm_resource_group" "fun-grp" {
  name     = "fun-grp-nov6-v3"
  location = "Canada Central"
}

resource "azurerm_storage_account" "fun-str-acc" {
  name                     = "funstracc9415"
  resource_group_name      = azurerm_resource_group.fun-grp.name
  location                 = azurerm_resource_group.fun-grp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "fun-serv-plan" {
  name                = "funservplan9415"
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
/*
   app_settings = {
    "ENABLE_ORYX_BUILD"              = "true"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "FUNCTIONS_WORKER_RUNTIME"       = "python"
    "AzureWebJobsFeatureFlags"       = "EnableWorkerIndexing"
   "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.application_insight.instrumentation_key
  }
*/
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
  storage_container_name =  azurerm_storage_container.mail-sender-code-container.name
  type                   = "Block"
  source                 = "./SendMailFunction/mail_sender_code.zip"
}