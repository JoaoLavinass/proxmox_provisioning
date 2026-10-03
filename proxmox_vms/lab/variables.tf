variable "vm_ip_address" {
  description = "IPv4 address assigned to the VM"
  type        = string
}

variable "vm_gateway" {
  description = "IPv4 gateway for the VM"
  type        = string
}

variable "vm_name" {
  description = "Virtual Machine name"
  type        = string
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
}

