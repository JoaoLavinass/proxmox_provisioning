provider "proxmox" {
  endpoint  = "https://192.168.1.188:8006/"
  api_token = "terraform@pve!tf-token=APIKEY"
  insecure  = true

  ssh {
    username = "root"
    agent    = true
  }
}
