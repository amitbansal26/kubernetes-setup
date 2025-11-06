# Security Policy

## Overview

This repository contains scripts and configurations for setting up Kubernetes clusters. Security is a critical concern when deploying production Kubernetes environments.

## Security Considerations

### Default Credentials

⚠️ **WARNING**: This repository uses default credentials for demonstration and testing purposes only.

**Default credentials that MUST be changed for production use:**

1. **Root Password**: `kubeadmin` (set in `initialize.sh`)
2. **SSH Authentication**: Password-based authentication is enabled by default
3. **Keepalived Auth Password**: `mysecret` (set in `loadbalancer.sh`)

### Hardcoded Secrets

The following files contain references to default passwords that should be parameterized or removed:

- `initialize.sh`: Root password setup
- `worker.sh`: SSH password for scp operation
- `loadbalancer.sh`: Keepalived authentication password

## Recommended Security Practices

### For Production Deployments

1. **Credential Management**
   - Use environment variables for sensitive data
   - Implement Ansible Vault for encrypted secrets
   - Never commit credentials to version control
   - Rotate passwords regularly

2. **SSH Hardening**
   - Disable password authentication
   - Use SSH key-based authentication only
   - Disable root login via SSH
   - Implement fail2ban or similar brute-force protection

3. **Network Security**
   - Review and restrict firewall rules to minimum required ports
   - Implement network policies in Kubernetes
   - Use private networks for cluster communication
   - Enable TLS for all API communication

4. **RBAC and Access Control**
   - Implement least privilege access
   - Use Kubernetes RBAC policies
   - Regularly audit access logs
   - Separate dev/staging/prod environments

5. **Container Security**
   - Scan container images for vulnerabilities
   - Use trusted base images
   - Implement pod security policies/standards
   - Run containers as non-root users

6. **Cluster Hardening**
   - Enable audit logging
   - Encrypt etcd data at rest
   - Use network policies
   - Keep Kubernetes and components updated

### Script Security Improvements

All shell scripts should:
- Quote variables to prevent word splitting
- Validate input parameters
- Avoid echoing sensitive information
- Use secure methods for credential passing

## Reporting a Vulnerability

If you discover a security vulnerability in this repository, please:

1. **Do Not** open a public issue
2. Email the repository maintainer directly
3. Provide detailed information about the vulnerability
4. Allow reasonable time for a fix before public disclosure

## Security Checklist for Deployment

- [ ] Change all default passwords
- [ ] Configure SSH key-based authentication
- [ ] Disable password-based SSH authentication
- [ ] Review and harden firewall rules
- [ ] Enable SELinux in enforcing mode (if applicable)
- [ ] Implement network policies
- [ ] Set up audit logging
- [ ] Configure RBAC policies
- [ ] Enable pod security standards
- [ ] Scan all container images
- [ ] Set up certificate management
- [ ] Configure encrypted communication
- [ ] Implement backup and disaster recovery
- [ ] Set up monitoring and alerting

## References

- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [NSA/CISA Kubernetes Hardening Guide](https://www.nsa.gov/Press-Room/News-Highlights/Article/Article/2716980/nsa-cisa-release-kubernetes-hardening-guidance/)
- [OWASP Kubernetes Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html)
