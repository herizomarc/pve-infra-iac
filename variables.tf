variable "pve_ip" {
  type        = string
  description = "Target Proxmox VE node management IP address"
  default     = "10.10.99.2"
}

variable "pve_port" {
  type        = string
  description = "Network port assigned to the Proxmox REST API interface"
  default     = "8006"
}

variable "ssh_public_key" {
  type        = string
  description = "Permanent SecOps public SSH key injected into cloud-init for emergency DRP access"
  # Declared empty to keep the codebase fully anonymous. GitLab CI fills this at runtime.
}
