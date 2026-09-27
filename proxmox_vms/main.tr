terraform {
  required_version = ">= 1.6.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78.0"
    }
  }
}

provider "proxmox" {
  # Change this to your Proxmox mini PC IP address
  endpoint  = "https://192.168.1.50:8006/" 
  api_token = "terraform@pve!tf-token=YOUR-UUID-SECRET-HERE"
  
  # Set to true if you are using a self-signed SSL certificate on Proxmox
  insecure  = true 
}

# Example: Define a cloud-init Ubuntu/Debian Virtual Machine
resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  node_name = "pve" # Match this to your Proxmox node name
  vm_id     = 100
  name      = "sre-lab-node-01"

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048 # 2GB RAM
  }

  disk {
    datastore_id = "local-lvm"
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
  }
}