variable "name" {
  type        = string
  description = "Name of the Azure Bastion resource."
  default     = "personal-bastion"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to deploy the bastion (and its subnet/public IP) into."
}

variable "location" {
  type        = string
  description = "Azure region to deploy the bastion into. Changing this and re-applying is how you 'jump region' for the bastion."
}

variable "virtual_network_id" {
  type        = string
  description = "Resource ID of the existing virtual network that will host the AzureBastionSubnet."
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the existing virtual network (used to create the AzureBastionSubnet in the same resource group)."
}

variable "bastion_subnet_address_prefix" {
  type        = string
  description = "Address prefix for the dedicated AzureBastionSubnet (must be /26 or larger)."
  default     = "10.0.255.0/26"
}

variable "sku" {
  type        = string
  description = "Azure Bastion SKU. 'Standard' or 'Premium' is required to enable native client tunneling (SSH/RDP from the CLI) used for personal jump-host access."
  default     = "Standard"
}

variable "tunneling_enabled" {
  type        = bool
  description = "Enable native client tunneling (az network bastion tunnel / az network bastion ssh) instead of only browser-based sessions."
  default     = true
}

variable "ip_connect_enabled" {
  type        = bool
  description = "Allow connecting directly to a private IP address behind the bastion (not just to a registered VM resource)."
  default     = true
}

variable "scale_units" {
  type        = number
  description = "Number of scale units for the bastion host (throughput/concurrent session capacity)."
  default     = 2
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the bastion resources."
  default     = {}
}
