# =======================================================
# SECURITY BOUNDARIES & ACCESS CREDENTIALS (SCHEMAS ONLY)
# =======================================================
variable "PROXMOX_URL" {
  type        = string
  sensitive   = true
  description = "Root REST API endpoint URL for Proxmox VE cluster virtualization layer"
}

variable "PROXMOX_TOKEN_ID" {
  type        = string
  sensitive   = true
  description = "Privileged Proxmox API Token Identifier, isolated from version control to prevent identity exposure"
}

variable "PROXMOX_TOKEN_SECRET" {
  type        = string
  sensitive   = true
  description = "Privileged Proxmox API Token Secret, isolated from version control to prevent identity exposure"
  
}

variable "SSH_PUBLIC_KEY" {
  type        = string
  sensitive   = true
  description = "SecOps public SSH key injected into the guest OS cloud-init metadata boundary at boot time (for emergency DRP access"
}

# ====================================================
# GLOBAL NETWORKING & INFRASTRUCTURE DEFAULT VARIABLES
# ====================================================
variable "pve_node_name" {
  type        = string
  default     = "pve1"
  description = "The target Proxmox VE hardware node name."
}

variable "pve_datastore_id" {
  type        = string
  default     = "local-lvm"
  description = "The default destination storage pool for virtual disks."
}

variable "network_bridge" {
  type        = string
  default     = "vmbr0"
  description = "The hypervisor network bridge interface mapped to the guest VMs."
}

variable "network_gateway" {
  type        = string
  default     = "10.10.99.1"
  description = "The default IPv4 gateway address for the virtualized network segment."
}

variable "admin_username" {
  type        = string
  default     = "secops"
  description = "The non-root localized administrative account username injected via cloud-init."
}

variable "golden_image_id" {
  type        = number
  default     = 9000
  description = "The immutable source template VM ID utilized for linked cloning routines."
}

# ============================================================
# MATRICIAL SCHEMA WITH DYNAMIC MULTI-DISK AND NETWORK SUPPORT
# ============================================================

 variable "virtual_machines" {
  type = map(object({
    vm_id       = number
    cpu_cores   = number
    memory_mb   = number
    ip_address  = optional(string)
    description = string
    storage_disks = list(object({
      interface = string
      size_gb   = number
    }))
    networks = optional(list(object({
      bridge     = string
      vlan_id    = optional(number)
      ip_address = string
      gateway    = optional(string)
    })))
  }))
  description = "The corporate scalable infrastructure topology map supporting variable disk and network structures."
}
