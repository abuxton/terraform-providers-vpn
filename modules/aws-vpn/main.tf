# Personal WireGuard VPN endpoint on AWS
#
# There is no actively-maintained WireGuard module in the Terraform Registry
# that supports current AWS provider versions (evaluated: vainkop/wireguard/aws
# and jmhale/terraform-aws-wireguard both pin the AWS provider to a legacy
# "= 3.32.0" version inside the module itself, which is incompatible with the
# rest of this project - see docs/DEPLOYMENT.md "Module evaluation notes").
# This module builds the same well-known pattern (single EC2 instance +
# cloud-init WireGuard bootstrap + optional Elastic IP) directly with native
# `aws_instance` resources so it stays compatible with modern provider
# versions and is easy to test with `terraform validate`/`plan`.
data "aws_ami" "ubuntu" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.ubuntu[0].id

  wg_peers_block = join("\n\n", [
    for p in var.peers : join("\n", [
      "[Peer]",
      "# ${p.name}",
      "PublicKey = ${p.public_key}",
      "AllowedIPs = ${p.allowed_ips}",
      "PersistentKeepalive = ${var.persistent_keepalive}",
    ])
  ])
}

resource "aws_security_group" "wireguard" {
  name        = "${var.name}-sg"
  description = "Personal WireGuard VPN endpoint"
  vpc_id      = var.vpc_id
  tags        = merge({ Name = "${var.name}-sg" }, var.tags)
}

resource "aws_security_group_rule" "wg_ingress" {
  type              = "ingress"
  from_port         = var.wg_server_port
  to_port           = var.wg_server_port
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.wireguard.id
  description       = "WireGuard tunnel"
}

resource "aws_security_group_rule" "ssh_ingress" {
  count             = length(var.allowed_ssh_cidrs) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ssh_cidrs
  security_group_id = aws_security_group.wireguard.id
  description       = "Emergency SSH access"
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.wireguard.id
}

resource "aws_instance" "wireguard" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.wireguard.id]
  source_dest_check      = false

  user_data = templatefile("${path.module}/cloud-init/wireguard-init.sh.tftpl", {
    wg_server_private_key = var.wg_server_private_key
    wg_server_address     = var.wg_server_address
    wg_server_port        = var.wg_server_port
    wg_peers_block        = local.wg_peers_block
  })

  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_eip" "wireguard" {
  count    = var.associate_eip ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.wireguard.id
  tags     = merge({ Name = "${var.name}-eip" }, var.tags)
}
