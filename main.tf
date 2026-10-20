# =========================================================================
# 📝 IN-MEMORY GENERATION OF THE IMMUTABLE BOUNDARY (NO HOST reliance)
# =========================================================================
data "cloudinit_config" "openbao_bootstrap" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
#cloud-config
# Pure SecOps bypass: Strictly disable automatic package lookups to ensure quick boot
package_update: false
package_upgrade: false
package_reboot_if_required: false
EOF
  }
}

# =========================================================================
# 💾 VIRTUAL METADATA UPLOAD VIA NETWORKING API (NEVER TOUCH THE HOST FILESYSTEM)
# =========================================================================
resource "proxmox_virtual_environment_file" "openbao_cloudinit" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve1"

  source_raw {
    data      = data.cloudinit_config.openbao_bootstrap.rendered
    file_name = "openbao-stateless-bypass.yaml"
  }
}

# =========================================================================
# 🔒 PROVISIONING DE LA VM OPENBAO
# =========================================================================
resource "proxmox_virtual_environment_vm" "openbao_server" {
  name        = "vm-openbao-prod-01"
  description = "Production OpenBao Vault Server - Clean OS Bootstrap"
  vm_id       = 102
  node_name   = "pve1"

  clone {
    vm_id = 9000
    full  = false
  }

  agent { enabled = true }
  cpu { 
    cores = 2 
    type = "host" 
    }

  memory { dedicated = 2048 }

  disk { 
    datastore_id = "local-lvm"
    interface    = "scsi0" # OS Root disk
    size         = 20 
  }
  
  disk { 
    datastore_id = "local-lvm"
    interface    = "scsi1" # ➔ REQUIS: Spécifie le bus matériel pour le disque de secrets
    size         = 15 
    file_format  = "raw" 
  }


  network_device { 
    bridge = "vmbr0"
    model = "virtio" 
       
    }

  initialization {
    ip_config {
      ipv4 {
        address = "10.10.99.20/24"
        gateway = "10.10.99.1"
      }
    }
    user_account {
      username = "secops"
      keys     = [var.ssh_public_key]
    }
    
    # ➔ INJECTION DE LA CONFIGURATION DE CONFINEMENT SANS FICHIER PHYSIQUE SUR L'HÔTE
    user_data_file_id = proxmox_virtual_environment_file.openbao_cloudinit.id
  }
}

# =========================================================================
# 🤖 AUTOMATED INVENTORY GENERATION FOR ANSIBLE
# =========================================================================
resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/ansible-inventory/hosts.ini"
  file_permission = "0644"
  content         = <<EOF
[openbao]
vm-openbao-prod-01 ansible_host=${split("/", proxmox_virtual_environment_vm.openbao_server.initialization[0].ip_config[0].ipv4[0].address)[0]} ansible_user=secops
EOF
}

