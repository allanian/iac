# proxmox
variable "proxmox_api_url" {}
variable "proxmox_user" {}
variable "proxmox_password" {}

# VM
variable "instances" {}
variable "vm_name" {}
variable "vm_cores" {}
variable "vm_sockets" {}
variable "vm_vcpus" {
  default="0"
}
variable "vm_memory" {}
variable "ssh_key" {}
variable "ssh_password" {}
variable "vm_disk_size" {}
#variable "ssh_private_key" {}
variable "ssh_user" {}
# network
variable "vm_nameserver" {}
variable "vm_searchdomain" {}
