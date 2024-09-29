#!/bin/bash

# Set error handling
unset DISPLAY
set -e

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if reboot is required
check_reboot_required() {
    if [ -f /var/run/reboot-required ]; then
        echo "1"
    else
        echo "0"
    fi
}

# Function to run command with or without sudo based on whether it's Proxmox
run_cmd() {
    if [ -f /etc/pve/.version ]; then
        eval "$@"
    else
        sudo "$@"
    fi
}

# Determine if this is a Proxmox system
is_proxmox=false
if [ -f /etc/pve/.version ]; then
    is_proxmox=true
    log "This is a Proxmox system."
fi

# Update package lists
log "Updating package lists..."
if $is_proxmox; then
    apt update -qq
elif command_exists apt-get; then
    run_cmd DEBIAN_FRONTEND=noninteractive apt-get update -qq
elif command_exists apt; then
    run_cmd DEBIAN_FRONTEND=noninteractive apt update -qq
else
    log "Error: Neither apt-get nor apt found. Exiting."
    exit 1
fi

# Function to check for updates
check_updates() {
    if $is_proxmox; then
        updates=$(apt list --upgradable 2>/dev/null | grep upgradable | wc -l)
    elif command_exists apt-get; then
        updates=$(run_cmd apt-get --just-print upgrade | grep ^Inst | wc -l)
    elif command_exists apt; then
        updates=$(run_cmd apt list --upgradable 2>/dev/null | grep upgradable | wc -l)
    else
        log "Error: No suitable method found to check for updates. Exiting."
        exit 1
    fi
    echo $updates
}

# Function to install updates
install_updates() {
    if $is_proxmox; then
        log "Installing updates on Proxmox..."
        apt dist-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" | tee /var/log/apt/apt-upgrade.log
    elif command_exists apt-get; then
        log "Installing updates using apt-get..."
        run_cmd DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" | tee /var/log/apt/apt-get-upgrade.log
    elif command_exists apt; then
        log "Installing updates using apt..."
        run_cmd DEBIAN_FRONTEND=noninteractive apt upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" | tee /var/log/apt/apt-upgrade.log
    else
        log "Error: No suitable method found to install updates. Exiting."
        exit 1
    fi
}

# Check for updates
log "Checking for system updates..."
updates_count=$(check_updates)
if [ "$updates_count" -eq 0 ]; then
    log "No updates available."
    exit 0
else
    log "Number of updates available: $updates_count"
    log "Proceeding with installation..."
    install_updates
fi

# Verify if updates were installed
if [ $? -eq 0 ]; then
    log "System updates have been successfully installed."
else
    log "Error occurred while installing system updates. Please check the log files in /var/log/apt/ for more details."
    exit 1
fi

# Perform Proxmox-specific updates if applicable
if $is_proxmox; then
    log "Performing Proxmox-specific updates..."
    if command_exists pveupgrade; then
        pveupgrade
    else
        log "pveupgrade command not found. Skipping Proxmox-specific updates."
    fi
fi

# Check if a reboot is required
reboot_required=$(check_reboot_required)
if [ "$reboot_required" -eq 1 ]; then
    log "A system reboot is required to complete the update process."
    echo "REBOOT_REQUIRED=1"  # This line can be used by your RMM to trigger a notification
else
    log "No reboot is required at this time."
    echo "REBOOT_REQUIRED=0"
fi

log "System update check and installation completed."