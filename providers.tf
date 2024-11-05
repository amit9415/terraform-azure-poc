terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.8.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "472c19a3-f586-48b4-9434-33082654efbb"
  features {}
}