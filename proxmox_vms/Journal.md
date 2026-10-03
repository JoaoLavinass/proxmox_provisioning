# 2026-09-27 — Initial Proxmox OpenTofu Configuration

## Objective

Create the first OpenTofu-managed VM in the Proxmox lab.

## Environment

- OpenTofu: 1.12.6
- Proxmox node: pve
- Provider: bpg/proxmox ~> 0.78.0

## Changes

- Added Proxmox provider.
- Configured API token authentication.
- Added `sre-lab-node-01`.
- Allocated 2 CPU cores.
- Allocated 2 GB RAM.
- Added 20 GB disk on `local-lvm`.
- Connected the VM to `vmbr0`.

## Validation

Commands executed:

```bash
tofu init
tofu validate
tofu plan
tofu apply
```
## Main issues 

When configuring connection parameters in OpenTofu to communicate with newly provisioned nodes, omitting agent = true inside the SSH block resulted in authentication failures.

**Cause:** Without an active SSH agent configured to handle key handshakes, OpenTofu could not securely authenticate against the target node during the provisioning phase.

**Resolution:** To establish a secure connection, a local SSH key pair was generated, loaded into a running ssh-agent instance, and the public key was copied to the remote Proxmox machine (or injected via Cloud-init)

Added the private SSH key to the agent:
```bash
ssh-add ~/.ssh/*id_creaed*
```
Ensured agent = true was explicitly defined in the OpenTofu connection block so it could seamlessly leverage the loaded agent keys:
Terraform
```
connection {
    type     = "ssh"
    user     = "root"
    host     = "192.168.1.51"
    agent    = true
}
```
Distributed the public key to the target remote machine to authorize incoming connections.
```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.1.188
```

--- 

## 2026-09-27 — Initial Proxmox OpenTofu Configuration

I was trying to structure my provisioning recipie, following this example:

```
infrastructure/
├── modules/
│   └── proxmox-vm/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── environments/
    ├── lab/
    │   ├── main.tf
    │   ├── providers.tf
    │   ├── variables.tf
    │   └── terraform.tfvars
    │
    └── prod/
        ├── main.tf
        ├── providers.tf
        ├── variables.tf
        └── terraform.tfvars
```
Each module can be mentioned like:

```
module "network" {
  source = "../../modules/proxmox-vm"

  cpu_core = 2
}
```
The next chapters is the developing this structure.

## 2026-10-03 — Modules configuration

Entry Update:
Variable Declarations: Ensured all variables used in the lab configuration are explicitly declared to properly ingest values from the terraform.tfvars file.

roxmox Cloud-Image Management: Addressed handling for existing cloud images when using the proxmox_virtual_environment_vm download resource. Going forward, we have three potential approaches:

- Delete the existing image file directly within Proxmox before running;
- Download and Rename the new image by specifying a unique file_name;
- Bypass/Remove the download step entirely if the image is already provisioned.

