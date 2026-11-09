# Terraform VPN modules

Reusable Terraform modules for personal VPN and bastion access across AWS and Azure.

| Module | What it creates | Terraform / provider requirement |
| --- | --- | --- |
| [`aws-vpn`](./modules/aws-vpn) | An Ubuntu WireGuard server, security group, and optional Elastic IP | Terraform >= 1.5; AWS provider >= 4.0, < 6.0 |
| [`aws-bastion`](./modules/aws-bastion) | An SSH bastion behind a load balancer, with session logs and authorized keys stored in S3 | Terraform >= 1.5; AWS provider >= 4.0, < 6.0 |
| [`azure-bastion`](./modules/azure-bastion) | Azure Bastion composition; currently requires an upstream-interface update | Terraform >= 1.9; AzureRM provider ~> 4.10 |

> [!IMPORTANT]
> These modules create infrastructure but do not configure cloud-provider credentials, virtual networks, subnets, or key pairs. Supply those from your root Terraform configuration.

## Getting started

1. Authenticate with the cloud provider and create or identify the prerequisite network resources.
2. Create a root Terraform configuration and reference a module with a local `source` path, as shown below.
3. Run `terraform init`, review `terraform plan`, then apply the configuration.

### AWS WireGuard VPN

The VPN module launches an Ubuntu 22.04 server in a public subnet. It opens the WireGuard UDP port to the internet, restricts optional SSH access to the CIDRs you provide, and allocates an Elastic IP by default.

```hcl
module "vpn" {
  source = "./modules/aws-vpn"

  region             = "us-east-1"
  vpc_id             = "vpc-0123456789abcdef0"
  subnet_id          = "subnet-0123456789abcdef0"
  key_name           = "personal-vpn"
  allowed_ssh_cidrs  = ["203.0.113.10/32"]

  peers = [
    {
      name        = "laptop"
      public_key  = "REPLACE_WITH_DEVICE_WIREGUARD_PUBLIC_KEY"
      allowed_ips = "10.8.0.2/32"
    },
  ]

  tags = {
    Environment = "personal"
  }
}
```

The default WireGuard server address is `10.8.0.1/24` and port is `51820`. Each peer's `allowed_ips` must be within that network. Set `wg_server_private_key` to retain the server key if the instance is replaced; otherwise, the module generates one at first boot. The module outputs the endpoint public IP, instance ID, security group ID, WireGuard port, and server address.

> [!WARNING]
> Keep `allowed_ssh_cidrs` restricted to trusted egress addresses. It is empty by default, but the WireGuard UDP port is intentionally reachable from the internet.

### AWS SSH bastion

This module wraps [`Guimove/bastion/aws`](https://registry.terraform.io/modules/Guimove/bastion/aws/latest) to deploy an SSH bastion with a load balancer and S3-backed session logs and public keys.

```hcl
module "bastion" {
  source = "./modules/aws-bastion"

  region                      = "us-east-1"
  vpc_id                      = "vpc-0123456789abcdef0"
  auto_scaling_group_subnets  = ["subnet-0123456789abcdef0"]
  elb_subnets                 = ["subnet-0fedcba9876543210"]
  bastion_host_key_pair       = "personal-bastion"
  bucket_name                 = "replace-with-a-globally-unique-bucket"
  cidrs                       = ["203.0.113.10/32"]
}
```

Use public load-balancer subnets when `is_lb_private` is `false` (the default). Set `create_dns_record` with `hosted_zone_id` and `bastion_record_name` to create a Route 53 record. Outputs include the bastion DNS name, security groups for the bastion and private instances, and the log bucket name.

### Azure Bastion (currently unavailable)

The Azure module is intended to create the required `AzureBastionSubnet`, a Standard static public IP, and an Azure Verified Module Bastion host with native client tunneling and IP connect enabled by default.

> [!CAUTION]
> The currently constrained Azure Verified Module interface requires `parent_id` and rejects this module's `resource_group_name` argument, so `terraform validate` fails. Update the wrapper to the compatible upstream interface before using this module.

When the interface is updated, the dedicated subnet prefix must be `/26` or larger. The module declares inputs for the existing resource group and virtual network, location, SKU, scale units, and tunneling features.

## Module inputs

The examples show the required inputs. Optional controls include instance type, resource names, tags, endpoint port, static server key, Elastic IP allocation, private load balancer selection, Route 53 DNS, Azure Bastion SKU, scale units, and tunneling features. See each module's `variables.tf` file for descriptions and defaults.

## Validate modules

Run Terraform commands from the module you are changing:

```sh
terraform -chdir=modules/aws-vpn init -backend=false
terraform -chdir=modules/aws-vpn validate

terraform -chdir=modules/aws-bastion init -backend=false
terraform -chdir=modules/aws-bastion validate
```

The Azure Bastion module currently does not validate; see its status above. Use `terraform fmt -check -recursive` to verify formatting across all module files.

## Repository layout

```text
modules/
├── aws-vpn/       # Deployable WireGuard VPN module
├── aws-bastion/   # Deployable SSH bastion module
├── azure-bastion/ # Azure Bastion wrapper requiring an upstream-interface update
├── azure-vpn/     # WireGuard cloud-init template only
├── gcp-vpn/       # WireGuard cloud-init template only
└── gcp-bastion/   # Reserved; no module implementation yet
```

> [!NOTE]
> `azure-bastion` requires an upstream-interface update before deployment. `azure-vpn` and `gcp-vpn` contain cloud-init templates only, and `gcp-bastion` has no implementation. None is a deployable Terraform module at this time.
