# Nexus OSS Repository Manager

This directory contains the setup script for deploying Sonatype Nexus OSS Repository Manager.

## Overview

Nexus Repository OSS is a universal repository manager that:
- Stores and distributes Maven, npm, NuGet, PyPI, and Docker artifacts
- Proxies and caches dependencies from remote repositories
- Provides a single source of truth for build artifacts

## Contents

- `nexus-setup.sh` - Installation script for Nexus OSS 3.58.1-02

## Prerequisites

- Ubuntu/Debian-based system
- OpenJDK 8 JRE
- Sufficient disk space (minimum 4GB recommended)
- sudo privileges

## Installation

### Automated Setup

Run the setup script:

```bash
cd nexus-oss
sudo bash nexus-setup.sh
```

### What the Script Does

1. Installs OpenJDK 8 JRE
2. Installs GPG (for package verification)
3. Creates a `nexus` system user and group
4. Downloads Nexus OSS 3.58.1-02
5. Verifies the download checksum
6. Extracts and configures Nexus
7. Sets up the working directory with proper permissions
8. Configures Nexus to:
   - Listen on 127.0.0.1 (localhost only)
   - Disable the setup wizard
   - Disable random password generation
   - Allow Groovy scripts for configuration

## Configuration

### Default Settings

- **Version**: 3.58.1-02
- **Install Location**: `/opt/nexus/`
- **Working Directory**: `/opt/nexus/sonatype-work/`
- **Default Port**: 8081 (configured to listen on localhost)
- **Default Credentials**: admin/admin123

### Post-Installation Configuration

After installation, you may want to:

1. **Configure systemd service** (not included in script):

   Create `/etc/systemd/system/nexus.service`:
   ```ini
   [Unit]
   Description=Nexus Repository Manager
   After=network.target

   [Service]
   Type=forking
   LimitNOFILE=65536
   ExecStart=/opt/nexus/nexus-3.58.1-02/bin/nexus start
   ExecStop=/opt/nexus/nexus-3.58.1-02/bin/nexus stop
   User=nexus
   Restart=on-abort
   TimeoutSec=600

   [Install]
   WantedBy=multi-user.target
   ```

   Enable and start:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable nexus
   sudo systemctl start nexus
   ```

2. **Set up reverse proxy** (Nginx example):

   ```nginx
   server {
       listen 80;
       server_name nexus.example.com;

       location / {
           proxy_pass http://127.0.0.1:8081;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

3. **Change default password**:
   - Access Nexus web UI
   - Login with admin/admin123
   - Change password immediately
   - Configure authentication as needed

### Advanced Configuration

Edit `/opt/nexus/sonatype-work/nexus3/etc/nexus.properties`:

```properties
# Application server settings
application-host=127.0.0.1
application-port=8081

# Database settings (H2 by default)
# For PostgreSQL or other databases, see Nexus documentation

# Data directory
nexus-work=/opt/nexus/sonatype-work/nexus3

# Context path (optional)
# nexus-context-path=/nexus
```

## Usage

### Starting Nexus

```bash
sudo -u nexus /opt/nexus/nexus-3.58.1-02/bin/nexus start
```

Or with systemd:
```bash
sudo systemctl start nexus
```

### Stopping Nexus

```bash
sudo -u nexus /opt/nexus/nexus-3.58.1-02/bin/nexus stop
```

Or with systemd:
```bash
sudo systemctl stop nexus
```

### Checking Status

```bash
sudo -u nexus /opt/nexus/nexus-3.58.1-02/bin/nexus status
```

Or with systemd:
```bash
sudo systemctl status nexus
```

### Accessing the Web UI

If configured with a reverse proxy:
```
http://nexus.example.com
```

Direct access (localhost only by default):
```
http://127.0.0.1:8081
```

## Repository Types

Nexus supports various repository formats:

### Maven Repositories
- **Proxy**: Cache artifacts from Maven Central
- **Hosted**: Store your own artifacts
- **Group**: Combine multiple repositories

### Docker Registry
Configure Docker to use Nexus as a registry:

```bash
docker login nexus.example.com:5000
docker tag myimage nexus.example.com:5000/myimage
docker push nexus.example.com:5000/myimage
```

### NPM Registry
Configure npm to use Nexus:

```bash
npm config set registry http://nexus.example.com/repository/npm-group/
```

### PyPI Repository
Configure pip to use Nexus:

```bash
pip config set global.index-url http://nexus.example.com/repository/pypi-group/simple
```

## Security Considerations

⚠️ **Important Security Notes**:

1. **Change Default Password**: The default admin password is `admin123`. Change it immediately.

2. **Configure HTTPS**: Use a reverse proxy with SSL/TLS for production deployments.

3. **Firewall Rules**: Restrict access to Nexus ports:
   ```bash
   sudo ufw allow from <trusted-network> to any port 8081
   ```

4. **Enable Security Realms**: Configure LDAP, Active Directory, or other authentication.

5. **Regular Backups**: Back up `/opt/nexus/sonatype-work/` regularly.

6. **Update Nexus**: Keep Nexus updated to the latest version for security patches.

## Backup and Restore

### Backup

```bash
# Stop Nexus
sudo systemctl stop nexus

# Backup the work directory
sudo tar -czf nexus-backup-$(date +%Y%m%d).tar.gz /opt/nexus/sonatype-work/

# Start Nexus
sudo systemctl start nexus
```

### Restore

```bash
# Stop Nexus
sudo systemctl stop nexus

# Restore from backup
sudo tar -xzf nexus-backup-YYYYMMDD.tar.gz -C /

# Fix permissions
sudo chown -R nexus:nexus /opt/nexus/sonatype-work/

# Start Nexus
sudo systemctl start nexus
```

## Troubleshooting

### Nexus Won't Start

Check logs:
```bash
tail -f /opt/nexus/sonatype-work/nexus3/log/nexus.log
```

Check Java:
```bash
java -version
```

Check permissions:
```bash
ls -la /opt/nexus/
sudo chown -R nexus:nexus /opt/nexus/
```

### Out of Memory

Edit `/opt/nexus/nexus-3.58.1-02/bin/nexus.vmoptions`:

```
-Xms2703m
-Xmx2703m
-XX:MaxDirectMemorySize=2703m
```

Adjust values based on available system memory.

### Port Already in Use

Check what's using port 8081:
```bash
sudo lsof -i :8081
```

Change Nexus port in `nexus.properties`:
```properties
application-port=8082
```

## Uninstallation

```bash
# Stop Nexus
sudo systemctl stop nexus
sudo systemctl disable nexus

# Remove systemd service
sudo rm /etc/systemd/system/nexus.service
sudo systemctl daemon-reload

# Remove Nexus user
sudo userdel nexus
sudo groupdel nexus

# Remove Nexus installation
sudo rm -rf /opt/nexus/
```

## References

- [Nexus Repository Manager Documentation](https://help.sonatype.com/repomanager3)
- [Sonatype Downloads](https://help.sonatype.com/repomanager3/download)
- [Nexus Configuration](https://help.sonatype.com/repomanager3/installation/configuring-the-runtime-environment)
- [Repository Management Best Practices](https://help.sonatype.com/repomanager3/repository-management)
