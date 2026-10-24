# Proxmox VE IaC Infrastructure Factory 🏗️

A declarative Infrastructure-as-Code workspace driven by OpenTofu to provision elastic, sovereign virtual servers on internal enterprise hypervisors.

## 🛠️ Architecture & Tech Stack
* **IaC Engine:** OpenTofu `1.8.4` (Standalone Stock Configuration).
* **Provider Channel:** Official `bpg/proxmox` infrastructure provider.
* **Runtime Layer:** Rootless container isolation driven via unprivileged `podman` namespaces.

## ⚡ Design Patterns & Practices
* **Non-Selective Autodetection:** Zero restrictive flags (`-var-file`). OpenTofu natively reads the matricial topology file `terraform.tfvars`.
* **SecOps Coexistence Layer:** Runner storage tokens and private credentials are automatically mapped in memory at runtime under the `secrets.auto.tfvars` overlay to prevent file collisions or secret leaks into Git.
* **Hardware Immutability:** Enforces `type = "nocloud"` local ISO metadata mappings to guarantee instant boot operations without external DNS resolution dependency.
