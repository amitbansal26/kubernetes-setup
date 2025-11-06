# Contributing to kubernetes-setup

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project follows a standard code of conduct:

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Assume good intentions

## How to Contribute

### Reporting Bugs

When reporting bugs, please include:

- Operating system and version
- Vagrant and VirtualBox/libvirt versions
- Kubernetes version being deployed
- Clear steps to reproduce the issue
- Expected vs actual behavior
- Relevant log outputs or error messages

### Suggesting Enhancements

Enhancement suggestions are welcome! Please:

- Check if the enhancement has already been suggested
- Provide a clear description of the proposed feature
- Explain why this enhancement would be useful
- Include examples of how it would work

### Code Contributions

We welcome code contributions! Areas that need help:

- Improving documentation
- Fixing shell script issues identified by shellcheck
- Adding support for additional Linux distributions
- Enhancing security features
- Improving error handling and logging

## Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/kubernetes-setup.git
   cd kubernetes-setup
   ```

3. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. Make your changes

5. Test your changes thoroughly

## Coding Standards

### Shell Scripts

- Use `#!/bin/bash` shebang
- Follow [shellcheck](https://www.shellcheck.net/) recommendations
- Quote all variables: `"$variable"` instead of `$variable`
- Use meaningful variable names
- Add comments for complex logic
- Include error handling with `set -e` or explicit checks
- Avoid hardcoding credentials or sensitive data

Example:
```bash
#!/bin/bash
set -euo pipefail

# Check arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>" >&2
    exit 1
fi

username="$1"
password="$2"
```

### YAML Files

- Use 2 spaces for indentation
- Follow Kubernetes manifest best practices
- Include comments for non-obvious configurations
- Validate YAML syntax before committing

### Ansible Playbooks

- Use descriptive task names
- Follow Ansible best practices
- Use variables for configuration values
- Include comments for complex tasks
- Test playbooks in a development environment

## Testing

### Shell Script Testing

Run shellcheck on modified scripts:
```bash
shellcheck *.sh
shellcheck nexus-oss/*.sh
```

### Vagrant Testing

Test Vagrant configurations:
```bash
vagrant validate
vagrant up --no-provision  # Test VM creation
vagrant provision          # Test provisioning
```

### Ansible Testing

Test Ansible playbooks:
```bash
cd k8-ansible
ansible-playbook --syntax-check playbook.yml
ansible-lint playbook.yml  # If ansible-lint is available
```

### Integration Testing

Before submitting:
1. Test the complete deployment in a clean environment
2. Verify all nodes join the cluster successfully
3. Test basic Kubernetes operations
4. Verify networking with a sample application

## Pull Request Process

1. **Update Documentation**: Update README.md and other docs if needed

2. **Test Your Changes**: Ensure all tests pass

3. **Commit Messages**: Use clear, descriptive commit messages
   ```
   Fix: Resolve quoting issues in initialize.sh
   
   - Quote all variables to prevent word splitting
   - Add error handling for missing arguments
   - Improve security by not echoing passwords
   ```

4. **Create Pull Request**:
   - Provide a clear title and description
   - Reference any related issues
   - List changes made
   - Include testing details

5. **Code Review**:
   - Address review comments promptly
   - Be open to suggestions and feedback
   - Update your PR based on review feedback

6. **Merge Requirements**:
   - All tests must pass
   - Code review approval required
   - Documentation updated if needed
   - No merge conflicts

## Commit Message Format

Use conventional commit format:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

Example:
```
feat: Add support for Ubuntu 22.04

- Update package installation for Ubuntu
- Add Ubuntu-specific configuration
- Update documentation with Ubuntu instructions
```

## Questions?

If you have questions about contributing:

- Open an issue with your question
- Refer to existing issues and PRs
- Check the documentation

Thank you for contributing to kubernetes-setup!
