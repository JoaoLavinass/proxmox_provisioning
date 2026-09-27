## Proxmox Infrastructure as Code

Infrastructure as Code (IaC) repository for managing my Proxmox VE environment using OpenTofu.

The purpose of this repository is twofold:

- Manage my Proxmox infrastructure declaratively.

- Document the process and decisions made while building the environment.

This repository is intentionally being developed incrementally. Each change should ideally leave behind enough documentation to understand what changed, why it changed, and what was learned.

This section as the main propose to automate the creation of Virtual Machines (VMs) in my proxmox remote server.

### Repository Goals

The long-term goal is to manage the Proxmox environment as much as possible through code.

Instead of manually creating and modifying virtual machines through the Proxmox web interface, the desired workflow is:

```
Change configuration
       │
       ▼
OpenTofu plan
       │
       ▼
Review proposed changes
       │
       ▼
OpenTofu apply
       │
       ▼
Proxmox infrastructure
```

### Initial Configuration

The initial configuration is intentionally small.

At this stage, the repository contains:

- An OpenTofu configuration.
- The Proxmox provider.
- Authentication using a Proxmox API token.
- A single Ubuntu/Debian-oriented virtual machine definition.
- Basic CPU, memory, disk, and network configuration.

The initial VM is:
```
Name:      sre-lab-node-01
VM ID:     100
Node:      pve
CPU:       2 cores
Memory:    2048 MB
Disk:      20 GB
Interface: SCSI
Network:   vmbr0
```

### Authorization

As you can see in my *main.tf* file I have a user configured **terraform@pve** which has the role as Administrator.

```bash
pveum user add terraform@pve
pveum aclmod / -user terraform@pve -role Administrator
pveum user token add terraform@pve tf-token --privsep=0
```
The above commands let you create an user, grant it roles and then generate an API token that allows you to execute terraform commands.

Commands executed to create VM:

```bash
tofu init
tofu plan
tofu apply
```
