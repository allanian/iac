terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.6.8"
    }
  }
}
# Configure the Proxmox Provider
provider "proxmox" {
    pm_api_url = var.proxmox_api_url
    pm_user = var.proxmox_user
    pm_password = var.proxmox_password
    # if you have a self-signed cert
    pm_tls_insecure = "true"
}

