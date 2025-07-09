# OpenVAS WSL Installation Scripts

Automated installation scripts for setting up OpenVAS (Greenbone Community Edition) in Windows Subsystem for Linux (WSL) environment with proper Windows integration.


## Prerequisites
- Windows 10 version 2004 or later, or Windows 11
- WSL 2 enabled
- Docker Desktop for Windows with WSL 2 support

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/OpenVAS-openEuler-wsl-scripts.git
   cd OpenVAS-openEuler-wsl-scripts
   ```

2. **Run the WSL setup script:**
   ```bash
   chmod +x setup-greenbone-windows-wsl.sh
   ./setup-greenbone-windows-wsl.sh
   ```

3. **Set up Windows port forwarding (Run as Administrator in PowerShell):**
   ```powershell
   .\setup-windows-port-forwarding.ps1
   ```

## Usage

### Accessing OpenVAS
After successful installation:
- **From WSL**: http://localhost:9392
- **From Windows**: http://localhost:9392 (after port forwarding setup)

### Default Credentials
- **Username**: admin
- **Password**: Set during installation

### Managing the Service

**Start OpenVAS containers:**
```bash
cd ~/greenbone-community-container
docker compose -f docker-compose-wsl.yml up -d
```

**Stop OpenVAS containers:**
```bash
docker compose -f docker-compose-wsl.yml down
```

**View logs:**
```bash
docker compose -f docker-compose-wsl.yml logs -f
```

**Check container status:**
```bash
docker compose -f docker-compose-wsl.yml ps
```

## Feed Status

OpenVAS requires feed data to perform vulnerability scans. After installation:

1. **Check feed status**: Visit http://localhost:9392/feedstatus
2. **Wait for completion**: Feeds should show 'Current' status (may take 30 minutes to several hours). Ensure all feeds are fully loaded before scanning

## License

This repo is licensed under the [MIT License](LICENSE).

## Acknowledgments

- [Greenbone Community Containers Guide](https://greenbone.github.io/docs/latest/22.4/container/index.html) for the OpenVAS docker scripts

## Support

For support and questions:
- Create an issue in this repository
- Consult the official documentation