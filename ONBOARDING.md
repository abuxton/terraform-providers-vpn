# Project onboarding

This guided path takes a new user from repository orientation to safely using and maintaining the Terraform modules. Complete the stages in order; each stage has five challenges and a verification checkpoint.

> [!IMPORTANT]
> The deployable modules are `aws-vpn` and `aws-bastion`. Do not deploy `azure-bastion` until its upstream Azure Verified Module interface mismatch is fixed. The Azure and GCP VPN directories contain templates only.

## Before you start

- Terraform 1.5 or later for AWS modules.
- AWS credentials configured locally with permission to create the requested resources.
- An existing VPC, suitable subnets, and an EC2 key pair.
- A locally generated WireGuard device key pair when using `aws-vpn`.

Never commit provider credentials, Terraform state, generated private keys, or a populated `.terraform/` directory.

## Stage 1: Orient yourself

**Goal:** Understand what this repository owns and what a consumer owns.

1. Read [`README.md`](./README.md) for supported-module status and prerequisites.
2. Read [`Project_Architecture_Blueprint.md`](./Project_Architecture_Blueprint.md) for module boundaries and dependency flow.
3. Identify the `versions.tf`, `variables.tf`, `main.tf`, and `outputs.tf` contract in `modules/aws-vpn`.
4. Explain why a caller, rather than a module, configures cloud credentials and remote state.
5. Identify which directories cannot yet be used as Terraform module sources.

**Checkpoint:** You can distinguish a deployable module from a cloud-init template and list the existing resources the caller must provide.

## Stage 2: Deploy a WireGuard endpoint

**Goal:** Plan and apply a personal VPN endpoint without widening access unnecessarily.

1. Create a separate root Terraform configuration outside this repository.
2. Configure the AWS provider in that root configuration and point a module block at `./modules/aws-vpn` while working locally.
3. Supply a VPC ID, a public subnet with an Internet Gateway route, and an existing EC2 key-pair name.
4. Generate a WireGuard key pair for each client device and pass only each device's **public** key through `peers`.
5. Set `allowed_ssh_cidrs` to known egress addresses, run `terraform init`, review `terraform plan`, and apply only after confirming the network changes.

The module outputs the endpoint public IP, WireGuard port, and server tunnel address. It does **not** create a client configuration or expose the generated server public key. Retrieve the server public key through an approved administrative path before creating a client configuration.

**Checkpoint:** The applied endpoint has a stable Elastic IP (unless intentionally disabled), the WireGuard UDP port is reachable, and SSH is either disabled or CIDR-restricted.

## Stage 3: Use an SSH bastion

**Goal:** Deploy the AWS bastion wrapper and reach private instances through it.

1. Choose Auto Scaling Group subnets and load-balancer subnets; use public load-balancer subnets when `is_lb_private = false`.
2. Choose a globally unique S3 bucket name for session logs and authorized public keys.
3. Restrict `cidrs`; do not retain the default `0.0.0.0/0` for a public bastion.
4. Apply the module and record the `bastion_dns_name` output.
5. Add each user's public SSH key to the upstream module's expected S3 `public-keys/` path and attach the private-instances security group output to workloads that should accept bastion SSH.

Set `create_dns_record = true` only when you also provide a hosted-zone ID and a fully qualified record name.

**Checkpoint:** You can explain the difference between the load balancer's security path and the security group that private instances must accept.

## Stage 4: Validate and modify modules

**Goal:** Make a safe, reviewable change to a module.

1. Add or adjust an input in `variables.tf` with a clear type, description, and conservative default.
2. Thread it through `main.tf` only where its behavior is needed.
3. Add an output only when callers need to consume the value.
4. Run formatting and module-local initialization/validation:

   ```sh
   terraform fmt -check -recursive
   terraform -chdir=modules/aws-vpn init -backend=false
   terraform -chdir=modules/aws-vpn validate
   terraform -chdir=modules/aws-bastion init -backend=false
   terraform -chdir=modules/aws-bastion validate
   ```

5. Update `README.md` and `Project_Architecture_Blueprint.md` whenever a public module contract or support status changes.

> [!NOTE]
> At present, repository-wide formatting reports an existing issue in `modules/aws-bastion/main.tf`. The AWS modules otherwise validate. The Azure module fails validation because of its upstream interface mismatch.

**Checkpoint:** Your change preserves module boundaries, has no unreviewed ingress or IAM expansion, and validates for the module you changed.

## Stage 5: Operate safely

**Goal:** Maintain deployed access infrastructure without losing security or recovery options.

1. Store Terraform state and any static `wg_server_private_key` in an approved protected backend or secret manager.
2. Pin a static WireGuard server private key if client continuity across instance replacement matters.
3. Rotate device keys, remove former peers from `peers`, and restrict `allowed_ssh_cidrs` whenever access changes.
4. Review upstream Registry module interfaces before updating their version constraints.
5. Treat changes to security groups, IAM, route tables, public IPs, and destroy plans as high-impact changes requiring careful plan review.

**Checkpoint:** You can recover access through the EC2 key pair or approved cloud administration path and can explain the implications of replacing the WireGuard instance.

## Progress record

Use the checklist below to track your path. A stage is complete when you can complete all five challenges and its checkpoint without referring to the answer.

- [ ] Stage 1 - repository orientation
- [ ] Stage 2 - WireGuard endpoint deployment
- [ ] Stage 3 - SSH bastion deployment
- [ ] Stage 4 - module validation and modification
- [ ] Stage 5 - secure operations

After completing all stages, use the architecture blueprint as the reference for adding a cloud or capability while preserving the module-per-concern design.
