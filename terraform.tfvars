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

    storage_disks = [
      { interface = "scsi0", size_gb = 20 },
      { interface = "scsi1", size_gb = 15 }
    ]
  }

  "k8s-cp" = {
    vm_id       = 110
    cpu_cores   = 2
    memory_mb   = 4096
    description = "Kubernetes Control Plane Node (kubeadm)"
    storage_disks = [{ interface = "scsi0", size_gb = 30 }]
    networks = [
      { bridge = "vmbr0", ip_address = "10.10.99.40/24" },
      { bridge = "vmbr1", vlan_id = 10, ip_address = "10.10.10.10/24", gateway = "10.10.10.1" }
    ]
  }

  "k8s-wk1" = {
    vm_id       = 111
    cpu_cores   = 4
    memory_mb   = 8192
    description = "Kubernetes Worker Node 01 (AWX & Core Workloads)"
    storage_disks = [{ interface = "scsi0", size_gb = 50 }]
    networks = [
      { bridge = "vmbr0", ip_address = "10.10.99.41/24" },
      { bridge = "vmbr1", vlan_id = 10, ip_address = "10.10.10.11/24", gateway = "10.10.10.1" }
    ]
  }

  "k8s-wk2" = {
    vm_id       = 112
    cpu_cores   = 4
    memory_mb   = 8192
    description = "Kubernetes Worker Node 02 (GitOps & Applications)"
    storage_disks = [{ interface = "scsi0", size_gb = 50 }]
    networks = [
      { bridge = "vmbr0", ip_address = "10.10.99.42/24" },
      { bridge = "vmbr1", vlan_id = 10, ip_address = "10.10.10.12/24", gateway = "10.10.10.1" }
    ]
  }
}


