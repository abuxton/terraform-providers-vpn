variable "name" {
  type        = string
  description = "Name prefix used for the bastion resources (tags, ASG/launch template name)."
  default     = "personal-bastion"
}

variable "region" {
  type        = string
  description = "AWS region to deploy the bastion into."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID in which the bastion will be deployed."
}

variable "auto_scaling_group_subnets" {
  type        = list(string)
  description = "Subnets (private or public) the bastion Auto Scaling Group launches instances into."
}

variable "elb_subnets" {
  type        = list(string)
  description = "Subnets used by the load balancer that fronts the bastion. Use public subnets for is_lb_private = false."
}

variable "is_lb_private" {
  type        = bool
  description = "Whether the bastion load balancer is internal only (true) or internet facing (false)."
  default     = false
}

variable "bastion_host_key_pair" {
  type        = string
  description = "Name of an existing EC2 key pair used as a fallback login for the bastion instances."
}

variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name used to store bastion SSH session logs and authorized public keys."
}

variable "cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to reach the bastion on the SSH port. Restrict this to your known egress IP(s) for a personal jump host."
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the bastion host."
  default     = "t3.micro"
}

variable "public_ssh_port" {
  type        = number
  description = "Public facing SSH port on the load balancer."
  default     = 22
}

variable "create_dns_record" {
  type        = bool
  description = "Whether to create a Route53 record for the bastion. Requires hosted_zone_id and bastion_record_name."
  default     = false
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for the bastion DNS record (required when create_dns_record = true)."
  default     = ""
}

variable "bastion_record_name" {
  type        = string
  description = "Fully qualified DNS record name for the bastion (required when create_dns_record = true)."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the bastion resources."
  default     = {}
}
