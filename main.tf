# ===============================
# PROVIDER REQUIREMENT BOUNDARIES
# ===============================
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.1" # Enforcing enterprise-grade stable release channel
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = "${var.pve_token_id}=${var.pve_token_secret}"
  insecure  = true # Bypassing self-signed internal TLS warning flags
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
  network_device {
    bridge = var.network_bridge # Injected dynamically from variables layer
    model  = "virtio"
  }

  # Cloud-Init System Level Initialization
  initialization {
    ip_config {
      ipv4 {
        address = each.value.ip_address
        gateway = var.network_gateway # Injected dynamically from variables layer
      }
    }

    user_account {
      username = var.admin_username # Injected dynamically from variables layer
      keys     = [var.ssh_public_key] # Dynamically injected at runtime from tfvars
    }

    upgrade = false # Enforcing pristine cloud-init 'done' logs to instantly release control to Ansible
  }
}

# =============================================================
# AUTOMATED DINAMIC INVENTORY GENERATION FOR GITOPS PROPAGATION
# =============================================================
resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/ansible-inventory/hosts.ini"
  file_permission = "0644"
  content         = <<EOF
[all_vms]
%{ for key, vm in proxmox_virtual_environment_vm.factory_server ~}
${vm.name} ansible_host=${split("/", vm.initialization[0].ip_config[0].ipv4[0].address)[0]} ansible_user=${var.admin_username}
%{ endfor ~}

[openbao]
vm-openbao-prod-01
EOF
}
