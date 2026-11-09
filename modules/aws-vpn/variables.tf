variable "name" {
  type        = string
  description = "Name prefix for the VPN resources."
  default     = "personal-vpn"
}

variable "region" {
  type        = string
  description = "AWS region to deploy the WireGuard VPN server into. Changing this and re-applying (with a fresh state or -target) is how you 'jump region' for the VPN endpoint."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID in which the WireGuard server will be launched."
}

variable "subnet_id" {
  type        = string
  description = "Public subnet for the WireGuard instance (needs a route to an Internet Gateway)."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the WireGuard server."
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI to use. Leave null to use the latest official Ubuntu 22.04 LTS AMI."
  default     = null
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name for emergency SSH access to the VPN instance."
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to SSH into the VPN instance. Restrict to your known IP(s)."
  default     = []
}

variable "wg_server_port" {
  type        = number
  description = "UDP port WireGuard listens on and that must be reachable from the internet. Changing this and re-applying is how you 'jump endpoint' (port) without changing region."
  default     = 51820
}

variable "wg_server_address" {
  type        = string
  description = "WireGuard interface address/CIDR on the server (e.g. 10.8.0.1/24). Peer allowed_ip values must fall inside this range."
  default     = "10.8.0.1/24"
}

variable "wg_server_private_key" {
  type        = string
  description = "Optional static WireGuard server private key. Leave empty to generate one on first boot (regenerates on instance replacement unless you pin this value)."
  default     = ""
  sensitive   = true
}

variable "peers" {
  type = list(object({
    name        = string
    public_key  = string
    allowed_ips = string
  }))
  description = "Personal devices allowed to connect. Generate a keypair per device with scripts/wg-add-client.sh and list its public key + tunnel IP (e.g. \"10.8.0.2/32\") here."
  default     = []
}

variable "persistent_keepalive" {
  type        = number
  description = "Keepalive interval (seconds) in generated client configs, useful behind NAT."
  default     = 25
}

variable "associate_eip" {
  type        = bool
  description = "Allocate and associate an Elastic IP so the endpoint address is stable across instance replacement."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the VPN resources."
  default     = {}
}
