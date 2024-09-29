#!/bin/bash

# Define the Wazuh manager and agent group
WAZUH_MANAGER='YOUR MANAGER DOMAIN'
WAZUH_AGENT_GROUP='GROUP NAME'

# Function to check if the script is run with root privileges
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root. Please use sudo or run as root."
        exit 1
    fi
}

# Function to detect the system architecture
detect_arch() {
    case $(uname -m) in
        x86_64) echo "amd64" ;;
        aarch64) echo "arm64" ;;
        armv7l) echo "armhf" ;;
        *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac
}

# Function to detect the Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "Unsupported distribution"
        exit 1
    fi
}

# Function to get the latest Wazuh agent version
get_latest_wazuh_version() {
    local distro=$1
    local arch=$2
    local repo_url

    case $distro in
        debian|ubuntu|linuxmint)
            repo_url="https://packages.wazuh.com/4.x/apt/"
            latest_version=$(curl -s $repo_url/dists/stable/main/binary-$arch/Packages | grep -oP 'Version: \K.*' | sort -V | tail -n 1)
            ;;
        fedora|rhel|centos)
            repo_url="https://packages.wazuh.com/4.x/yum/"
            latest_version=$(curl -s $repo_url | grep -oP 'wazuh-agent-\K[0-9.]+(?=-1)' | sort -V | tail -n 1)
            ;;
        *)
            echo "Unsupported distribution for version detection: $distro"
            exit 1
            ;;
    esac

    echo $latest_version
}

# Function to install Wazuh agent on Debian-based systems
install_wazuh_debian() {
    local arch=$1
    local version=$2

    # Add Wazuh repository
    curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
    echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

    apt-get update
    apt-get install -y wazuh-agent=$version-1
}

# Function to install Wazuh agent on Red Hat-based systems
install_wazuh_redhat() {
    local version=$1

    rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH
    cat > /etc/yum.repos.d/wazuh.repo << EOF
[wazuh]
gpgcheck=1
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
enabled=1
name=Wazuh repository
baseurl=https://packages.wazuh.com/4.x/yum/
protect=1
EOF

    yum install -y wazuh-agent-$version
}

# Function to install Wazuh agent
install_wazuh() {
    local distro=$1
    local arch=$2
    local version=$3

    case $distro in
        debian|ubuntu|linuxmint)
            install_wazuh_debian $arch $version
            ;;
        fedora|rhel|centos)
            install_wazuh_redhat $version
            ;;
        *)
            echo "Unsupported distribution: $distro"
            exit 1
            ;;
    esac

    # Configure Wazuh agent
    /var/ossec/bin/agent-auth -m $WAZUH_MANAGER -A $HOSTNAME -G $WAZUH_AGENT_GROUP
    sed -i "s/^WAZUH_MANAGER=.*/WAZUH_MANAGER='$WAZUH_MANAGER'/" /var/ossec/etc/ossec.conf
}

# Function to comment out Wazuh repository
comment_out_wazuh_repo() {
    local distro=$1

    case $distro in
        debian|ubuntu|linuxmint)
            sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/wazuh.list
            ;;
        fedora|rhel|centos)
            sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/wazuh.repo
            ;;
    esac

    echo "Wazuh repository has been commented out to prevent automatic updates."
}

# Main script execution
check_root
arch=$(detect_arch)
distro=$(detect_distro)
latest_version=$(get_latest_wazuh_version $distro $arch)

echo "Detected architecture: $arch"
echo "Detected distribution: $distro"
echo "Latest Wazuh agent version: $latest_version"

install_wazuh $distro $arch $latest_version

# Reload systemd, enable and start wazuh-agent
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent

# Check if Wazuh agent is running
if systemctl is-active --quiet wazuh-agent; then
    echo "Wazuh agent is running successfully."
    comment_out_wazuh_repo $distro
else
    echo "Wazuh agent failed to start. Please check the logs for more information."
fi

echo "Wazuh agent installation and configuration completed."