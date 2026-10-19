# =========================================================================
# 🔒 SECURE OPENBAO VAULT INSTANCE (DEDICATED SECURE VM)
# =========================================================================
resource "proxmox_virtual_environment_vm" "openbao_server" {
  name        = "vm-openbao-prod-01"
  description = "Production OpenBao Secret Vault Server - Secure API Provisioning"
  vm_id       = 102
  node_name   = "pve1"

  # ➔ Link to your hardened CIS/ANSSI RHEL 9 Golden Image Template (ID 9000)
  clone {
    vm_id = 9000
    full  = false # Linked clone architecture for lightning-fast deployments
  }

  # ➔ Hardware Provisioning Layout
  agent {
    enabled = true # Communicates natively with the pre-baked QEMU Guest Agent
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  # ➔ Decoupled Storage Provisioning (CIS Boundary Hardening Compliance)
  # SCSI 0: Main system disk inheriting the pre-baked golden image CIS partitioning
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 20
  }

  # SCSI 1: Isolated, dedicated data disk explicitly reserved for OpenBao Raft DB storage (/srv/openbao)
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi1"
    size         = 15
    file_format  = "raw"
  }

  # ➔ Network Device Mapping
  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # ➔ Cloud-Init System Level Initialization
  initialization {
    ip_config {
      ipv4 {
        address = "10.10.99.20/24"
        gateway = "10.10.99.1"
      }
    }

    user_account {
      username = "secops" # Safe, localized non-root administrative account
      keys     = [var.ssh_public_key] # Dynamically injected at runtime from tfvars
    }
  }
}

# =========================================================================
# 🤖 GÉNÉRATION AUTOMATISÉE DE L'INVENTAIRE DYNAMIQUE POUR ANSIBLE
# =========================================================================
resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/ansible-inventory/hosts.ini"
  file_permission = "0644"
  content         = <<EOF
[openbao]
vm-openbao-prod-01 ansible_host=${split("/", proxmox_virtual_environment_vm.openbao_server.initialization.ip_config.ipv4.address)[0]} ansible_user=secops
EOF
}