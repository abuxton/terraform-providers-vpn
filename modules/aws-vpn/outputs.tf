output "vpn_public_ip" {
  description = "Public IP address of the WireGuard VPN endpoint."
  value       = var.associate_eip ? aws_eip.wireguard[0].public_ip : aws_instance.wireguard.public_ip
}

output "instance_id" {
  description = "EC2 instance ID of the VPN server."
  value       = aws_instance.wireguard.id
}

output "security_group_id" {
  description = "Security group ID attached to the VPN instance."
  value       = aws_security_group.wireguard.id
}

output "wg_server_port" {
  description = "UDP port the WireGuard server listens on."
  value       = var.wg_server_port
}

output "wg_server_address" {
  description = "WireGuard server tunnel address/CIDR."
  value       = var.wg_server_address
}
