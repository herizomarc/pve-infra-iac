terraform {
  required_version = ">= 1.8.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.60.0" # Modern standard provider for Proxmox VE 8/9
    }
  }
}

provider "proxmox" {
  # Dynamically interpolates target hypervisor connection details
  endpoint = "https://${var.pve_ip}:${var.pve_port}/"
  insecure = true
}
