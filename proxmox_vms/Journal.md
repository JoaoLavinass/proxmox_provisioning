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
