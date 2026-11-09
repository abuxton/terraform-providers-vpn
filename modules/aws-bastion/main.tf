# AWS SSH bastion (jump host)
#
# Wraps the community "Guimove/bastion/aws" registry module, which builds an
# Auto Scaling Group of a single instance behind a load balancer, logs every
# SSH session to S3, and manages bastion users by dropping their SSH public
# key into the bucket's /public-keys/ path.
#
# Registry: https://registry.terraform.io/modules/Guimove/bastion/aws
module "bastion" {
  source  = "Guimove/bastion/aws"
  version = "~> 3.0"

  region                     = var.region
  vpc_id                     = var.vpc_id
  bucket_name                = var.bucket_name
  bastion_host_key_pair      = var.bastion_host_key_pair
  bastion_launch_template_name = "${var.name}-lt"
  bastion_iam_role_name      = "${var.name}-role"
  bastion_iam_policy_name    = "${var.name}-policy"
  is_lb_private              = var.is_lb_private
  auto_scaling_group_subnets = var.auto_scaling_group_subnets
  elb_subnets                = var.elb_subnets
  cidrs                      = var.cidrs
  instance_type               = var.instance_type
  public_ssh_port             = var.public_ssh_port
  create_dns_record           = var.create_dns_record
  hosted_zone_id               = var.hosted_zone_id
  bastion_record_name          = var.bastion_record_name

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
