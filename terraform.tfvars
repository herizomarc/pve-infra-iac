# ===================================================================
# MATRICIAL INSTANTIATION MAP: DATA-DRIVEN INFRASTRUCTURE DECLARATION
# ===================================================================
virtual_machines = {
  "openbao-prod" = {
    vm_id       = 102
    cpu_cores   = 2
    memory_mb   = 2048
    ip_address  = "10.10.99.20/24"
    description = "Production Sovereign OpenBao Secret Vault Server"
    
    # OpenBao specific layout: 20GB for OS (scsi0), 15GB for Raft Database (scsi1)
    storage_disks = [
      { interface = "scsi0", size_gb = 20 },
      { interface = "scsi1", size_gb = 15 }
    ]
  }
}

