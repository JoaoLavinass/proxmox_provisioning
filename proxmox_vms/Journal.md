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


## 2026-10-03 - Network Segmentation & Virtual Routing (VLANs)

For this next project I would like to implement VLANs so I must understand some basic stuf:

**linux bridge:** Is a logical construct in proxmox that's allows you to connect the physical adaptors into proxmox and also helping proxmox to understand VLANs. 

**bridge ports:** represents the physical adaptor(s) that back the linux bridge

There are two ways to create VLANs, which are:

**Access Port:** access port is a type of switch port that lets untagged traffic move between end devices and the network. It’s assigned to one VLAN, making sure the traffic from the connected device stays within that specific VLAN

**Trunk Port:** it connects switches together and carry traffic for multiple VLANs using VLAN tagging (based on the 802.1Q standard).


On the file /etc/network/interfaces it is possible to see the Network devices and also which network device is being used by the linux bridge (as default vmbr0).


---

### Approach

To achieve enterprise-grade network segmentation and stateful security on single-port hardware (Mini PC), we bypass native hypervisor routing in favor of an edge-virtualized architecture. 

By separating traffic into a WAN bridge (vmbr0) tied to the physical interface and an internal VLAN-aware software switch (vmbr1), a virtualized firewall appliance (OPNsense) can act as the core router. This isolates workloads into distinct security zones (Management, Servers, and IoT) while maintaining clean separation of concerns between hypervisor compute and network data planes.

```
[ HOME ISP ROUTER ] (192.168.1.0/24)
         │
         ▼ (Physical Cable)
   [ Proxmox Host ]
         ├── vmbr0 (WAN Bridge - gets IP from ISP)
         │      │
         │      └─► OPNsense VM (net0: WAN)
         │
         └─► vmbr1 (Internal Virtual Trunk / VLAN Aware)
                │
                ├─► VLAN 20 (Servers) ──► OPNsense (net1: LAN) ──► Allowed to Internet (WAN)
                │
                └─► VLAN 30 (IoT/Lab)  ──► OPNsense (net1: LAN) ──► Blocked from Internet (WAN)
```

#### Architecture & Access Pattern

**Hypervisor:** Proxmox VE (pve at 192.168.1.188)

**Router Firewall:** OPNsense VM (LAN IP: 192.168.10.1)

**Bridges:** vmbr0 (WAN) and vmbr1 (LAN Trunk)

**GUI Management Tunnel:** Because of OPNsense's default-deny security posture, access to the web interface is tunneled through Proxmox:
Bash

ssh -L 8080:192.168.10.1:80 root@192.168.1.188

(Access via browser at http://localhost:8080)

#### Critical SRE Caveat (The Firewall Trap):

Every time network changes or interface updates are applied in the OPNsense GUI, the packet filter state table flushes and rules reset, cutting off active management traffic and SSH tunnels. To regain access or troubleshoot from the host, drop into the OPNsense console shell and temporarily disable the packet filter:

```bash
/sbin/pfctl -d
```
#### Step-by-Step Configuration Guide

**Step 1:** Create the VLAN Definitions

Define the VLAN tags to ride on the physical/virtual LAN trunk interface (vtnet1).

Navigate in OPNsense GUI to Interfaces -> Other Types -> VLAN.

Create VLAN 20:

- Parent interface: vtnet1 (LAN)

- VLAN tag: 20

- Description: VLAN20

Create VLAN 30:

- Parent interface: vtnet1 (LAN)

- VLAN tag: 30

- Description: VLAN30

Click Apply changes. (Remember to run /sbin/pfctl -d on the OPNsense console if the UI drops).

**Step 2:** Assign the VLAN Interfaces

Convert the definitions into active virtual network interfaces.

Go to Interfaces -> Assignments.

Under Assign a new interface, select vtnet1_vlan20 (or similar), name it VLAN20, and click +.

Select vtnet1_vlan30, name it VLAN30, and click +.

Click Save.

**Step 3:** Configure Gateway IP Addresses

Assign static gateway IPs so connected VMs know their routing target.

Click VLAN20 under Interfaces:

- Enable interface: Checked

- IPv4 Configuration: Static IPv4

- IPv4 address: 192.168.20.1 / 24

- Click Save.

Click VLAN30 under Interfaces:

- Enable interface: Checked

- IPv4 Configuration: Static IPv4

- IPv4 address: 192.168.30.1 / 24

- Click Save.

- Click Apply changes.

**Step 4:** Enable DHCP Services

Configure automatic IP assignment for machines spinning up on these subnets.

Go to Services -> DHCPv4.

VLAN20 Tab:

- Enable DHCP server on VLAN20 interface.

- Range: 192.168.20.100 to 192.168.20.200

- Click Save.

VLAN30 Tab:

- Enable DHCP server on VLAN30 interface.

- Range: 192.168.30.100 to 192.168.30.200

- Click Save.

Useful SRE Command Reference

Check listening ports/sockets:

```bash
sockstat -4 -l
```
Restart OPNsense Web GUI service:

```bash
configctl webgui restart
```

Toggle OPNsense Firewall (pf):

```bash
/sbin/pfctl -d  # Disable firewall (troubleshooting/access recovery)
/sbin/pfctl -e  # Enable firewall
```