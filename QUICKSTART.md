# Quick Start Guide

This guide will help you quickly set up a Kubernetes cluster using this repository.

## Prerequisites Check

Before starting, ensure you have:

- [ ] Vagrant installed (`vagrant --version`)
- [ ] VirtualBox or libvirt installed
- [ ] At least 8GB of free RAM
- [ ] Red Hat subscription account (username and password)

## Quick Setup (Single Master)

### Step 1: Clone the Repository

```bash
git clone https://github.com/amitbansal26/kubernetes-setup.git
cd kubernetes-setup
```

### Step 2: Configure Environment

Copy and edit the example environment file:

```bash
cp .env.example .env
# Edit .env with your actual RHEL credentials
nano .env  # or use your preferred editor
```

### Step 3: Update Vagrantfile

Edit the `Vagrantfile` and set your credentials:

```ruby
username="your-rhel-username"
password="your-rhel-password"
```

**Security Note**: For better security, consider using environment variables:

```ruby
username=ENV['RHSM_USERNAME'] || ""
password=ENV['RHSM_PASSWORD'] || ""
```

### Step 4: Start the Cluster

```bash
vagrant up
```

This will:
- Create 1 master node (172.16.16.100)
- Create 2 worker nodes (172.16.16.101, 172.16.16.102)
- Install Kubernetes and configure the cluster
- Set up Calico networking

### Step 5: Access the Cluster

SSH into the master node:

```bash
vagrant ssh master1
```

Verify the cluster:

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

## Quick Setup (High Availability - 3 Masters)

For a production-like HA setup:

### Step 1-2: Same as above

### Step 3: Use HA Vagrantfile

```bash
cp Vagrantfile.2 Vagrantfile
```

Edit credentials in the new Vagrantfile.

### Step 4: Start HA Cluster

```bash
vagrant up
```

This will create:
- 3 master nodes (172.16.16.101, 172.16.16.102, 172.16.16.103)
- 2 load balancers (172.16.16.51, 172.16.16.52)
- Virtual IP: 172.16.16.100 (managed by Keepalived)

### Step 5: Access the HA Cluster

```bash
vagrant ssh master1
kubectl get nodes
```

## Using Ansible Instead

If you prefer Ansible over Vagrant:

### Step 1: Prepare Your Hosts

You'll need existing RHEL 9 servers. Update the inventory file:

```bash
cd k8-ansible
nano inventory
```

### Step 2: Configure Variables

Edit group variables:

```bash
nano group_vars/all.yml
```

Set your RHEL credentials (preferably using ansible-vault):

```bash
ansible-vault create group_vars/vault.yml
```

### Step 3: Run the Playbook

```bash
ansible-playbook -i inventory playbook.yml --ask-vault-pass
```

## Post-Installation

### Install Nginx Ingress Controller

```bash
kubectl apply -f nginx-ingress/ingress-service-account.yaml
kubectl apply -f nginx-ingress/admission-service-account.yaml
kubectl apply -f nginx-ingress/configmap.yaml
kubectl apply -f nginx-ingress/services.yaml
kubectl apply -f nginx-ingress/deployment.yaml
kubectl apply -f nginx-ingress/ingressclass.yaml
kubectl apply -f nginx-ingress/validating-webhook.yaml
kubectl apply -f nginx-ingress/jobs.yaml
```

### Install MetalLB Load Balancer

```bash
kubectl apply -f nginx-ingress/metallb.yaml
kubectl apply -f nginx-ingress/metal-config.yaml
```

### Deploy a Test Application

```bash
# Create a simple nginx deployment
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
kubectl get svc nginx
```

## Troubleshooting

### Vagrant Issues

**VM not starting:**
```bash
vagrant destroy
vagrant up
```

**Network issues:**
```bash
vagrant reload
```

**Check VM status:**
```bash
vagrant status
```

### Kubernetes Issues

**Nodes not joining:**
```bash
# On master
sudo cat /joincluster.sh

# On worker, manually run:
sudo bash /joincluster.sh
```

**Pod networking issues:**
```bash
kubectl get pods -n calico-system
kubectl logs -n calico-system <pod-name>
```

**Check kubelet logs:**
```bash
sudo journalctl -u kubelet -f
```

### Subscription Manager Issues

**Registration fails:**
- Verify credentials are correct
- Check network connectivity
- Ensure subscription is active

**Clean up failed registration:**
```bash
sudo subscription-manager clean
```

## Next Steps

- [ ] Deploy sample applications
- [ ] Set up persistent storage
- [ ] Configure monitoring (Prometheus/Grafana)
- [ ] Set up logging (ELK/Loki)
- [ ] Implement backup strategy
- [ ] Review security settings (see SECURITY.md)

## Cleanup

### Destroy Vagrant VMs

```bash
vagrant destroy -f
```

### Reset Cluster (Keep VMs)

```bash
# SSH to each node and run:
sudo kubeadm reset -f
sudo rm -rf /etc/kubernetes/
sudo rm -rf /var/lib/kubelet/
sudo rm -rf /var/lib/etcd/
```

## Getting Help

- Check the [README.md](README.md) for detailed documentation
- Review [SECURITY.md](SECURITY.md) for security best practices
- See [CONTRIBUTING.md](CONTRIBUTING.md) if you want to contribute
- Open an issue on GitHub for bugs or questions

## Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Vagrant Documentation](https://www.vagrantup.com/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Project YouTube Tutorial](https://www.youtube.com/watch?v=hq9iaROZr8s)
