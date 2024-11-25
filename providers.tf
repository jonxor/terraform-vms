terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
    dns = {
      source = "hashicorp/dns"
      version = "3.3.2"
    }
  }
}
