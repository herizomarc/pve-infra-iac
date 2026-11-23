# ===============================
# PROVIDER REQUIREMENT BOUNDARIES
# ===============================
terraform {

  backend "http" {}
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.1" # Enforcing enterprise-grade stable release channel
    }
  }
}

provider "proxmox" {
  endpoint  = var.PROXMOX_URL 
  api_token = "${var.PROXMOX_TOKEN_ID}=${var.PROXMOX_TOKEN_SECRET}"
  insecure  = true # Bypassing self-signed internal TLS warning flags
}

locals {
  vm_networks = {
    for k, v in var.virtual_machines : k => v.networks != null ? v.networks : [
      {
        bridge     = var.network_bridge
        vlan_id    = null
        ip_address = v.ip_address
        gateway    = var.network_gateway
      }
    ]
  }
}


# ==========================================================
# IAAS COMPUTE PROVISIONING LAYER (FOR_EACH DECOUPLING LOOP)
# ==========================================================
resource "proxmox_virtual_environment_vm" "factory_server" {
  for_each = var.virtual_machines

  name        = "vm-${each.key}-01"
  description = each.value.description
  vm_id       = each.value.vm_id
  node_name   = var.pve_node_name # Injected dynamically from variables layer

  # Link to hardened  RHEL 9 Golden Image Template (ID 9000)
  clone {
    vm_id = var.golden_image_id # Injected dynamically from variables layer
    full  = false # Utilizing fast linked-clone copy-on-write allocation hooks
  }

  # Hardware Provisioning Layout
  agent {
    enabled = true # Communicates natively with the pre-baked QEMU Guest Agent
  }

  cpu {
    cores = each.value.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory_mb
  }

  # HIGHLY SCALABLE LOGIC: Loop through variable multi-disk arrays dynamically
  dynamic "disk" {
    for_each = each.value.storage_disks
    content {
      datastore_id = var.pve_datastore_id # Injected dynamically from variables layer
      interface    = disk.value.interface
      size         = disk.value.size_gb
      file_format  = disk.value.interface == "scsi0" ? "raw" : "raw" # Conditional checks can be applied here
    }
  }

  # Network Device Mapping
  dynamic "network_device" {
    for_each = local.vm_networks[each.key]
    content {
      bridge  = network_device.value.bridge
      vlan_id = network_device.value.vlan_id
      model   = "virtio"
    }
  }

  # Cloud-Init System Level Initialization
  initialization {
    dns {
      servers = ["10.10.99.11"]
    }

    dynamic "ip_config" {
      for_each = local.vm_networks[each.key]
      content {
        ipv4 {
          address = ip_config.value.ip_address
          gateway = ip_config.value.gateway
        }
      }
    }

    user_account {
      username = var.admin_username
      keys     = [var.SSH_PUBLIC_KEY]
    }
  }
}

# ==========================================================
# STATE IMPORT: ATTACH OPENBAO TO STATE (ID 102)
# ==========================================================
import {
  to = proxmox_virtual_environment_vm.factory_server["openbao-prod"]
  id = "pve1/102"
}
