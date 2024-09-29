#!/bin/bash
# Function to check if the script is run with root privileges

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root. Please use sudo or run as root."
        exit 1
    fi
}

# Function to detect the current non-root user
detect_user() {
    if [ "$SUDO_USER" ]; then
        echo "$SUDO_USER"
    elif [ "$USER" != "root" ]; then
        echo "$USER"
    else
        echo ""
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

# Function to install Docker on Debian-based systems
install_docker_debian() {
    local arch=$1
    apt-get update
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$ID/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$arch signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$ID $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# Function to install Docker on Red Hat-based systems
install_docker_redhat() {
    dnf -y install dnf-plugins-core
    dnf config-manager --add-repo https://download.docker.com/linux/$ID/docker-ce.repo
    dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# Function to install Docker on Arch-based systems
install_docker_arch() {
    pacman -Sy --noconfirm docker docker-compose
}

# Function to install Docker on SUSE-based systems
install_docker_suse() {
    zypper addrepo https://download.docker.com/linux/sles/docker-ce.repo
    zypper refresh
    zypper install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# Function to install Docker
install_docker() {
    local distro=$1
    local arch=$2
    case $distro in
        debian|ubuntu|linuxmint)
            install_docker_debian $arch
            ;;
        fedora|rhel|centos)
            install_docker_redhat
            ;;
        arch|manjaro)
            install_docker_arch
            ;;
        opensuse*|sles)
            install_docker_suse
            ;;
        *)
            echo "Unsupported distribution: $distro"
            exit 1
            ;;
    esac
}

# Function to add user to docker group
add_user_to_docker_group() {
    local user=$1
    if [ -n "$user" ]; then
        usermod -aG docker "$user"
        echo "User $user has been added to the docker group."
    fi
}

# Main script execution
check_root
current_user=$(detect_user)
arch=$(detect_arch)
distro=$(detect_distro)

echo "Detected architecture: $arch"
echo "Detected distribution: $distro"
echo "Current user: $current_user"

install_docker $distro $arch
systemctl daemon-reload
systemctl enable --now docker

docker version

add_user_to_docker_group "$current_user"

echo "Docker has been installed and configured."
echo "Please log out and log back in for the group changes to take effect."