# 1. Download the OPNsense ISO directly into Proxmox
# 1. Download the OPNsense DVD ISO directly into Proxmox
resource "proxmox_virtual_environment_download_file" "opnsense_iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  file_name = "OPNsense-24.7-dvd-amd64.iso"

  url = "https://pkg.opnsense.org/releases/24.7/OPNsense-24.7-dvd-amd64.iso.bz2"
  decompression_algorithm = "bz2"
}

resource "proxmox_virtual_environment_vm" "opnsense_router" {
  name      = "opnsense-router"
  node_name = "pve"

  tags = [
    "router",
    "firewall",
    "opnsense"
  ]

  bios = "ovmf"

  memory {
    dedicated = 4096
  }

  cpu {
    cores = 2
    type  = "host"
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    size         = 32
    discard      = "on"
  }

  cdrom {
    file_id  = proxmox_virtual_environment_download_file.opnsense_iso.id
    interface = "ide2"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  boot_order = [
    "ide2",
    "virtio0"
  ]
}
