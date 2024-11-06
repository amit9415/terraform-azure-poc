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

resource "azuread_application_app_role_assignment" "email_sender_permission" { 
  principal_object_id = azuread_service_principal.email_sender_sp.object_id 
  app_role_id         = "c7e6d6e1-4a3b-4e9a-b7a3-4e7fdf4c1f6c" # Mail.Send permission ID 
  resource_id         = "00000003-0000-0000-c000-000000000000" # Microsoft Graph 
} 

output "client_id" {
  value = azuread_application.app.client_id
}

output "client_secret" {
  value     = azuread_application_password.secret.value
  sensitive = true
}

