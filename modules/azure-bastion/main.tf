# Azure Bastion (managed jump-host PaaS service)
#
# Unlike the AWS/GCP bastion patterns (a VM you SSH into), Azure Bastion is a
# fully managed service: you connect to *other* VMs in the VNet through it
# via the Azure Portal, the az CLI (`az network bastion ssh` /
# `az network bastion tunnel`), or a native client - Azure operates the jump
# host for you. This module provisions the dedicated AzureBastionSubnet, a
# Standard public IP, and wraps Microsoft's official Azure Verified Module.
#
# Registry: https://registry.terraform.io/modules/Azure/avm-res-network-bastionhost/azurerm
data "azurerm_resource_group" "bastion" {
  name = var.resource_group_name
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet" # name is mandatory and fixed by Azure
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.bastion_subnet_address_prefix]
}

resource "azurerm_public_ip" "bastion" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

module "azure_bastion" {
  source  = "Azure/avm-res-network-bastionhost/azurerm"
  version = "0.9.0"

  name               = var.name
  parent_id          = data.azurerm_resource_group.bastion.id
  location           = var.location
  sku                = var.sku
  scale_units        = var.scale_units
  tunneling_enabled  = var.tunneling_enabled
  ip_connect_enabled = var.ip_connect_enabled
  zones              = coalesce(azurerm_public_ip.bastion.zones, toset([]))

  ip_configuration = {
    name                 = "${var.name}-ipconfig"
    subnet_id            = azurerm_subnet.bastion.id
    create_public_ip     = false
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = var.tags
}
