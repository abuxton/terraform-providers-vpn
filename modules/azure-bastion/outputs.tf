output "bastion_id" {
  description = "Resource ID of the Azure Bastion host."
  value       = module.azure_bastion.resource_id
}

output "bastion_dns_name" {
  description = "DNS name of the Azure Bastion host (used for native client tunneling)."
  value       = module.azure_bastion.dns_name
}

output "bastion_public_ip" {
  description = "Public IP address associated with the Azure Bastion host."
  value       = azurerm_public_ip.bastion.ip_address
}
