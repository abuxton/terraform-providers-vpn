terraform {
  # The upstream Azure/avm-res-network-bastionhost module requires >= 1.9.
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.10"
    }
  }
}
