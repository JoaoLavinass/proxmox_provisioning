module "virtual_machine" {
  source = "../modules"

  vm_name       = var.vm_name
  vm_ip_address = var.vm_ip_address
  vm_gateway    = var.vm_gateway
  cpu_cores     = var.cpu_cores
  ssh_public_key = file("~/.ssh/id_rsa.pub")
}
