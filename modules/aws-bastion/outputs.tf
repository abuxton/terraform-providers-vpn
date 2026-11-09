output "bastion_dns_name" {
  description = "DNS name of the bastion load balancer used to SSH into the bastion (falls back to bastion_record_name when create_dns_record = true)."
  value       = var.create_dns_record ? var.bastion_record_name : module.bastion.elb_ip
}

output "bastion_security_group_id" {
  description = "Security group ID(s) attached to the bastion instances."
  value       = module.bastion.bastion_host_security_group
}

output "private_instances_security_group_id" {
  description = "Security group ID to attach to private instances that should accept SSH from the bastion."
  value       = module.bastion.private_instances_security_group
}

output "bucket_name" {
  description = "S3 bucket storing bastion session logs and authorized public keys (drop <username>.pub under /public-keys/)."
  value       = module.bastion.bucket_name
}
