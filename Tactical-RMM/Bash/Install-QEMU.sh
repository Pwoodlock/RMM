#!/bin/bash

# This script supports Debian, Ubuntu, Linux Mint, Fedora, RHEL, CentOS, Arch Linux, Manjaro, openSUSE, and SLES. It should cover most major distributions and their derivatives.



# Function to check if the script is run with root privileges
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root. Please use sudo or run as root."
        exit 1
    fi
}

# Function to detect the system architecture
detect_arch() {
    arch=$(uname -m)
    case $arch in
        x86_64)
            echo "x86_64"
            ;;
        aarch64)
            echo "arm64"
            ;;
        armv7l)
            echo "armhf"
            ;;
        *)
            echo "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
}

# Function to detect the Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo $ID
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        echo $DISTRIB_ID
    else
        echo "Unsupported distribution"
        exit 1
    fi
}

# Function to install and enable qemu-guest-agent
install_qemu_guest_agent() {
    local distro=$1
    case $distro in
        debian|ubuntu|linuxmint)
            apt update
            apt install -y qemu-guest-agent
            ;;
        fedora|rhel|centos)
            dnf install -y qemu-guest-agent
            ;;
        arch|manjaro)
            pacman -Sy --noconfirm qemu-guest-agent
            ;;
        opensuse*|sles)
            zypper install -y qemu-guest-agent
            ;;
        *)
            echo "Unsupported distribution: $distro"
            exit 1
            ;;
    esac

    systemctl enable --now qemu-guest-agent
}

# Main script execution
check_root
arch=$(detect_arch)
distro=$(detect_distro)

echo "Detected architecture: $arch"
echo "Detected distribution: $distro"

install_qemu_guest_agent $distro

echo "QEMU Guest Agent has been installed and enabled."