# Define a data block to fetch the object_id from the currently signed Azure AD account
data "azuread_client_config" "current" {}


resource "azuread_application" "app" {
  display_name     = "tf-app"
  sign_in_audience = "AzureADMultipleOrgs"
  owners           = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "sp" {
  client_id = azuread_application.app.client_id
}

#Generate client secret
resource "azuread_application_password" "secret" {
   application_id    = azuread_application.app.id
}

output "client_id" {
  value = azuread_application.app.client_id
}

output "client_secret" {
  value     = azuread_application_password.secret.value
  sensitive = true
}