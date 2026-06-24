# RDS Deployments Automation Collection

Ansible collection for 5G RDS (Radio Deployment Suite) deployments - both Core and RAN - on OpenShift.

## Collection: `rhpds.rds_deployments`

This collection provides Ansible roles for deploying and managing 5G Core and RAN network functions on OpenShift using the Red Hat CNF Reference Design Specification (RDS).

## Roles

### `ocp4_workload_5gcore_deployments_lab`

Deploy and configure 5G Core RDS lab environment on OpenShift 4.20.

**Features:**
- Automated deployment of 5G Core infrastructure
- OpenShift 4.18, 4.19, and 4.20 support
- Disconnected/connected deployment modes
- Hub and MNO cluster provisioning
- ODF storage configuration
- Fast upgrade capabilities

**Variables:** See `roles/ocp4_workload_5gcore_deployments_lab/defaults/main.yml`

### `ocp4_workload_5gran_deployments_lab`

Deploy and configure 5G RAN (Radio Access Network) deployments lab environment on OpenShift 4.21.

**Features:**
- 5G RAN deployment automation
- OpenShift 4.21 support
- SNO (Single Node OpenShift) support
- Disconnected catalog mirroring
- Fast upgrade workflows

**Variables:** See `roles/ocp4_workload_5gran_deployments_lab/defaults/main.yml`

## Installation

### From Git Repository

```yaml
# requirements.yml
collections:
  - name: https://github.com/rhpds/rds-deployments-automation.git
    type: git
    version: main
```

```bash
ansible-galaxy collection install -r requirements.yml
```

## Usage

### Using in AgnosticV Catalog Items

```yaml
requirements_content:
  collections:
    - name: https://github.com/rhpds/rds-deployments-automation.git
      type: git
      version: main

software_workloads:
  bastions:
    - rhpds.rds_deployments.ocp4_workload_5gcore_deployments_lab
```

### Direct Playbook Usage

```yaml
---
- name: Deploy 5G Core RDS Lab
  hosts: bastions
  become: true
  roles:
    - rhpds.rds_deployments.ocp4_workload_5gcore_deployments_lab
```

## Requirements

- Ansible 2.15+
- OpenShift 4.18+ (for 5gcore role)
- OpenShift 4.21+ (for 5gran role)
- RHEL 9+ bastion host
- Minimum 64 CPUs, 200GB RAM on hypervisor

## Authors

- Tyrell Reddy <treddy@redhat.com>
- Mario Vazquez Cebrian <mavazque@redhat.com>

## License

Apache-2.0

## Source

Based on roles from:
- https://github.com/redhat-cop/agnosticd (PR #9779)
- https://github.com/RHsyseng/5g-core-deployments-on-ocp-lab
- https://github.com/RHsyseng/5g-ran-deployments-on-ocp-lab
