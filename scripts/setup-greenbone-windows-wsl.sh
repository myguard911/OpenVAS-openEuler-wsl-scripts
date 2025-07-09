#!/bin/bash
# Greenbone Community Edition Setup for Windows/WSL
# Based on official documentation: https://greenbone.github.io/docs/latest/22.4/container/index.html

set -e

DOWNLOAD_DIR=$HOME/greenbone-community-container
RELEASE="22.4"
WSL_IP=""

echo "=== Greenbone Community Edition Setup for Windows/WSL ==="
echo

# Function to check if command exists
installed() {
    local failed=0
    if [ -z "$2" ]; then
        if ! [ -x "$(command -v "$1")" ]; then
            failed=1
        fi
    else
        local ret=0
        "$@" &> /dev/null || ret=$?
        if [ "$ret" -ne 0 ]; then
            failed=1
        fi
    fi

    if [ $failed -ne 0 ]; then
        echo "ERROR: $* is not available."
        echo "Please install Docker Desktop for Windows with WSL 2 support."
        echo "See: https://docs.docker.com/desktop/windows/wsl/"
        exit 1
    fi
}

# Check prerequisites
echo "Checking prerequisites..."
installed curl
installed docker
installed docker compose version
echo "✓ All prerequisites met"
echo

# Get WSL IP for port forwarding setup
echo "Getting WSL IP address..."
WSL_IP=$(hostname -I | awk '{print $1}')
echo "WSL IP: $WSL_IP"
echo

# Create download directory
mkdir -p "$DOWNLOAD_DIR" && cd "$DOWNLOAD_DIR"

# Download the latest docker-compose file
echo "Downloading latest docker-compose file..."
curl -f -O https://greenbone.github.io/docs/latest/_static/docker-compose.yml
echo "✓ Docker compose file downloaded"
echo

# Modify docker-compose.yml for Windows/WSL compatibility
echo "Configuring for Windows/WSL environment..."
# Create a modified version that binds to all interfaces instead of just localhost
sed 's/127.0.0.1:9392:80/9392:80/' docker-compose.yml > docker-compose-wsl.yml
echo "✓ Configuration updated for WSL"
echo

# Pull images
echo "Pulling Greenbone Community Container images..."
echo "This may take several minutes depending on your internet connection..."
docker compose -f "$DOWNLOAD_DIR"/docker-compose-wsl.yml pull
echo "✓ Images pulled successfully"
echo

# Start containers
echo "Starting Greenbone Community Containers..."
docker compose -f "$DOWNLOAD_DIR"/docker-compose-wsl.yml up -d
echo "✓ Containers started"
echo

# Set admin password
echo "Setting up admin user..."
read -r -s -p "Enter password for admin user: " password
echo
docker compose -f "$DOWNLOAD_DIR"/docker-compose-wsl.yml \
    exec -u gvmd gvmd gvmd --user=admin --new-password="$password"
echo "✓ Admin password set"
echo

# Display access information
echo "=== Setup Complete ==="
echo
echo "Greenbone Security Assistant (GSA) will be available at:"
echo "  - WSL: http://localhost:9392"
echo "  - WSL: http://$WSL_IP:9392"
echo
echo "Windows Port Forwarding (run in Windows Command Prompt as Administrator):"
echo "  netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=9392 connectaddress=$WSL_IP connectport=9392"
echo
echo "Then access from Windows at: http://localhost:9392"
echo
echo "Login credentials:"
echo "  Username: admin"
echo "  Password: [the password you just set]"
echo
echo "IMPORTANT: Feed data is loading in the background."
echo "This process may take 30 minutes to several hours."
echo "Scans will show insufficient results until feeds are fully loaded."
echo
echo "Check feed status at: http://localhost:9392/feedstatus"
echo "Feeds should show 'Current' status before running scans."
echo
echo "=== Windows-specific Notes ==="
echo "1. To access from Windows, set up port forwarding (command shown above)"
echo "2. You can scan your WSL system by targeting: $WSL_IP"
echo "3. To scan other systems, ensure they're reachable from WSL"
echo
echo "Press Enter to continue..."
read

# Show running containers
echo "Current container status:"
docker compose -f "$DOWNLOAD_DIR"/docker-compose-wsl.yml ps
echo
echo "To view logs: docker compose -f $DOWNLOAD_DIR/docker-compose-wsl.yml logs -f"
echo "To stop: docker compose -f $DOWNLOAD_DIR/docker-compose-wsl.yml down"
echo "To restart: docker compose -f $DOWNLOAD_DIR/docker-compose-wsl.yml up -d" 