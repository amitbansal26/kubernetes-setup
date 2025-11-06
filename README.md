# kubernetes-setup

[![YouTube Tutorial](https://img.youtube.com/vi/hq9iaROZr8s/0.jpg)](https://www.youtube.com/watch?v=hq9iaROZr8s)

A comprehensive repository for setting up Kubernetes clusters using Vagrant and Ansible on RHEL 9 systems.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Repository Structure](#repository-structure)
- [Setup Methods](#setup-methods)
- [Security Considerations](#security-considerations)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Overview

This repository provides automated tools for deploying Kubernetes clusters using:
- **Vagrant**: For creating virtual machine environments
- **Ansible**: For configuration management and automation
- **Calico**: For pod networking
- **MetalLB**: For load balancing
- **Nginx Ingress**: For ingress controller

## Prerequisites

### Required Software
- [Vagrant](https://www.vagrantup.com/) (tested with latest version)
- [VirtualBox](https://www.virtualbox.org/) or [libvirt](https://libvirt.org/)
- [Ansible](https://www.ansible.com/) (for Ansible-based deployments)
- Red Hat subscription credentials (required for RHEL 9)

### System Requirements
- **Master Node**: 2 CPUs, 2GB RAM minimum
- **Worker Node**: 2 CPUs, 4GB RAM minimum
- **Host System**: Sufficient resources to run multiple VMs

## Repository Structure

```
.
├── initialize.sh           # Initial setup script for all nodes
├── master.sh              # Master node setup script
├── worker.sh              # Worker node setup script
├── loadbalancer.sh        # Load balancer setup with HAProxy/Keepalived
├── create-image-tar.sh    # Script to create container image tars
├── Vagrantfile            # Vagrant configuration for single master setup
├── Vagrantfile.2          # Vagrant configuration for HA setup (3 masters)
├── calico.yaml            # Calico network configuration
├── k8-ansible/            # Ansible playbooks and roles
├── nginx-ingress/         # Nginx ingress controller manifests
└── nexus-oss/            # Nexus OSS repository setup scripts
```

## Setup Methods

### Method 1: Vagrant with Single Master

1. Clone the repository:
   ```bash
   git clone https://github.com/amitbansal26/kubernetes-setup.git
   cd kubernetes-setup
   ```

2. Configure credentials in `Vagrantfile`:
   ```ruby
   username="your-rhel-username"
   password="your-rhel-password"
   ```

3. Start the cluster:
   ```bash
   vagrant up
   ```

### Method 2: Vagrant with HA Setup (3 Masters)

1. Use `Vagrantfile.2` for high availability setup:
   ```bash
   cp Vagrantfile.2 Vagrantfile
   ```

2. Configure your RHEL credentials in the Vagrantfile

3. Deploy the cluster:
   ```bash
   vagrant up
   ```

### Method 3: Ansible Playbooks

1. Navigate to the ansible directory:
   ```bash
   cd k8-ansible
   ```

2. Configure your inventory file with target hosts

3. Set up RHEL credentials in group_vars

4. Run the playbook:
   ```bash
   ansible-playbook -i inventory playbook.yml
   ```

## Security Considerations

### Default Credentials

**⚠️ IMPORTANT**: This repository uses default credentials for demonstration purposes. **These must be changed in production environments.**

Default credentials used:
- Root password: `kubeadmin`
- Keepalived auth password: `mysecret`

### Changing Default Passwords

1. **Root password**: Modify `initialize.sh` line with `passwd root`
2. **SSH password**: Update `worker.sh` where sshpass is used
3. **Keepalived password**: Update `loadbalancer.sh` in the keepalived configuration

### Best Practices

- Never commit credentials to version control
- Use environment variables or secure vaults (e.g., Ansible Vault) for sensitive data
- Change all default passwords immediately after deployment
- Disable password authentication and use SSH keys in production
- Review and harden firewall rules for your specific environment

## Usage

### Accessing the Cluster

After successful deployment:

```bash
# SSH to master node
vagrant ssh master1

# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces
```

### Installing Nginx Ingress Controller

```bash
kubectl apply -f nginx-ingress/
```

### Installing MetalLB

```bash
kubectl apply -f nginx-ingress/metallb.yaml
kubectl apply -f nginx-ingress/metal-config.yaml
```

## Configuration

### Network Configuration

- Pod Network CIDR: `20.96.0.0/12`
- Service Network: Default Kubernetes service network
- Master Node IP: `172.16.16.100`
- Worker Node IPs: `172.16.16.101`, `172.16.16.102`

### Customization

Edit the following files to customize your deployment:
- `Vagrantfile`: VM resources, IP addresses, node count
- `calico.yaml`: Pod network CIDR and Calico settings
- `k8-ansible/group_vars/`: Ansible variables and configurations

## Troubleshooting

### Common Issues

1. **Subscription Manager Fails**: Verify RHEL credentials
2. **Network Issues**: Check firewall rules and SELinux settings
3. **Pod Network Issues**: Verify Calico installation and CIDR configuration

### Logs

- Kubeadm init log: `/root/kubeinit.log` on master node
- Kubelet logs: `journalctl -u kubelet`
- Container runtime logs: `journalctl -u containerd`

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Calico Documentation](https://docs.projectcalico.org/)
- [Vagrant Documentation](https://www.vagrantup.com/docs)
- [YouTube Tutorial](https://www.youtube.com/watch?v=hq9iaROZr8s)
