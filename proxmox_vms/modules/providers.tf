provider "proxmox" {
  endpoint  = "https://192.168.1.188:8006/"
  api_token = "terraform@pve!tf-token=abfbe8df-994a-43f5-ab97-2aa3c0cefc05"
  insecure  = true

  ssh {
    username = "root"
    agent    = true
  }
}
