variable "pve_endpoint" {
  type        = string
  description = "Target Proxmox VE REST API endpoint URL root (e.g., https://10.10.99)"
}

variable "pve_token_id" {
  type        = string
  description = "Proxmox API Token ID allocation profile"
}

variable "pve_token_secret" {
  type        = string
  description = "Proxmox API Token Cryptographic Secret UUID"
  sensitive   = true
}

variable "ssh_public_key" {
  type        = string
  description = "Permanent SecOps public SSH key injected into cloud-init for emergency DRP access"
}
