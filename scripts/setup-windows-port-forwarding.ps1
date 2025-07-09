# PowerShell script to set up port forwarding for Greenbone Community Edition
# Run this script as Administrator in Windows PowerShell

param(
    [string]$WSL_IP = ""
)

Write-Host "=== Greenbone Windows Port Forwarding Setup ===" -ForegroundColor Green
Write-Host ""

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

# Get WSL IP if not provided
if ([string]::IsNullOrWhiteSpace($WSL_IP)) {
    Write-Host "Getting WSL IP address..."
    try {
        # Try to get WSL IP from wsl command
        $WSL_IP = (wsl hostname -I).Split()[0].Trim()
        if ([string]::IsNullOrWhiteSpace($WSL_IP)) {
            throw "Could not get IP from WSL"
        }
    } catch {
        Write-Host "Could not automatically detect WSL IP." -ForegroundColor Yellow
        $WSL_IP = Read-Host "Please enter your WSL IP address (run 'hostname -I' in WSL)"
    }
}

Write-Host "WSL IP: $WSL_IP" -ForegroundColor Cyan
Write-Host ""

# Remove existing port proxy if it exists
Write-Host "Removing any existing port forwarding rules..."
try {
    netsh interface portproxy delete v4tov4 listenaddress=127.0.0.1 listenport=9392 2>$null
    netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=9392 2>$null
} catch {
    # Ignore errors - rule might not exist
}

# Add new port forwarding rule
Write-Host "Setting up port forwarding for Greenbone (port 9392)..."
try {
    netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=9392 connectaddress=$WSL_IP connectport=9392
    Write-Host "✓ Port forwarding configured successfully!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to set up port forwarding: $_" -ForegroundColor Red
    exit 1
}

# Verify the configuration
Write-Host ""
Write-Host "Current port forwarding rules:"
netsh interface portproxy show v4tov4

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "You can now access Greenbone from Windows at:" -ForegroundColor Cyan
Write-Host "  http://localhost:9392" -ForegroundColor White
Write-Host ""
Write-Host "To remove port forwarding later, run:" -ForegroundColor Yellow
Write-Host "  netsh interface portproxy delete v4tov4 listenaddress=127.0.0.1 listenport=9392" -ForegroundColor Gray
Write-Host ""

# Ask if user wants to open browser
$openBrowser = Read-Host "Would you like to open Greenbone in your browser now? (y/N)"
if ($openBrowser -eq "y" -or $openBrowser -eq "Y") {
    Start-Process "http://localhost:9392"
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 