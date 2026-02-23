#!/bin/bash
# Script to uninstall Docker Engine from Linux (Ubuntu/Debian/Fedora/RHEL)
# Author: GitHub Copilot
# Date: 2026-01-30
# Note: This script completely removes Docker Engine and its data

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}🐳 Docker Engine Uninstaller${NC}"

# Function to check if running as root or with sudo
check_privileges() {
    if [[ $EUID -ne 0 ]]; then
        if ! sudo -v &>/dev/null; then
            echo -e "${RED}❌ This script requires administrator privileges!${NC}"
            echo -e "${YELLOW}💡 Run with: sudo $0${NC}"
            exit 1
        fi
    fi
}

# Function to detect the distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO=$ID
        echo -e "${GREEN}✅ Distribution detected: $DISTRO${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not detect distribution, using generic methods${NC}"
        DISTRO="unknown"
    fi
}

# Function to check if Docker is installed
check_docker_installed() {
    if command -v docker &>/dev/null; then
        DOCKER_VERSION=$(docker --version 2>/dev/null || echo "unknown")
        echo -e "${GREEN}✅ Docker found: $DOCKER_VERSION${NC}"
        return 0
    else
        echo -e "${YELLOW}ℹ️  Docker is not installed. Nothing to do.${NC}"
        return 1
    fi
}

# Function to confirm uninstallation (only in interactive mode)
confirm_uninstall() {
    # If not interactive terminal, skip confirmation
    if [[ ! -t 0 ]]; then
        return 0
    fi
    
    echo ""
    echo -e "${YELLOW}⚠️  WARNING: This action will remove:${NC}"
    echo -e "   • Docker Engine (docker-ce, docker-ce-cli)"
    echo -e "   • Containerd"
    echo -e "   • Docker Buildx and Compose plugins"
    echo -e "   • All Docker images, containers and volumes"
    echo -e "   • Docker configurations"
    echo ""
    
    read -p "❓ Do you want to continue? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
        echo -e "${RED}❌ Operation cancelled by user.${NC}"
        exit 0
    fi
}

# Function to stop containers and service
stop_docker() {
    echo -e "${YELLOW}🛑 Stopping Docker service...${NC}"
    
    # Try to stop via systemctl or service
    if command -v systemctl &>/dev/null; then
        sudo systemctl stop docker.service 2>/dev/null || true
        sudo systemctl stop docker.socket 2>/dev/null || true
        sudo systemctl stop containerd.service 2>/dev/null || true
    else
        sudo service docker stop 2>/dev/null || true
    fi
    
    # Kill remaining processes
    sudo pkill -9 dockerd 2>/dev/null || true
    sudo pkill -9 containerd 2>/dev/null || true
    
    echo -e "${GREEN}   ✓ Docker service stopped${NC}"
}

# Function to clean containers, images and volumes
cleanup_docker_data() {
    # Check if docker is still accessible
    if ! command -v docker &>/dev/null; then
        return 0
    fi
    
    echo -e "${YELLOW}🛑 Stopping all containers...${NC}"
    if sudo docker ps -aq 2>/dev/null | grep -q .; then
        sudo docker stop $(sudo docker ps -aq) 2>/dev/null || true
        echo -e "${GREEN}   ✓ Containers stopped${NC}"
    else
        echo -e "${YELLOW}   (no containers found)${NC}"
    fi
    
    echo -e "${YELLOW}🗑️ Removing all containers...${NC}"
    if sudo docker ps -aq 2>/dev/null | grep -q .; then
        sudo docker rm -f $(sudo docker ps -aq) 2>/dev/null || true
        echo -e "${GREEN}   ✓ Containers removed${NC}"
    else
        echo -e "${YELLOW}   (no containers to remove)${NC}"
    fi
    
    echo -e "${YELLOW}🗑️ Removing all images...${NC}"
    if sudo docker images -aq 2>/dev/null | grep -q .; then
        sudo docker rmi -f $(sudo docker images -aq) 2>/dev/null || true
        echo -e "${GREEN}   ✓ Images removed${NC}"
    else
        echo -e "${YELLOW}   (no images to remove)${NC}"
    fi
    
    echo -e "${YELLOW}🗑️ Removing all volumes...${NC}"
    if sudo docker volume ls -q 2>/dev/null | grep -q .; then
        sudo docker volume rm -f $(sudo docker volume ls -q) 2>/dev/null || true
        echo -e "${GREEN}   ✓ Volumes removed${NC}"
    else
        echo -e "${YELLOW}   (no volumes to remove)${NC}"
    fi
    
    echo -e "${YELLOW}🗑️ Removing custom networks...${NC}"
    sudo docker network prune -f 2>/dev/null || true
    echo -e "${GREEN}   ✓ Networks removed${NC}"
}

# Function to uninstall packages on Ubuntu/Debian
uninstall_docker_debian() {
    echo -e "${YELLOW}📦 Uninstalling Docker packages...${NC}"
    
    # Set to not ask for confirmation
    export DEBIAN_FRONTEND=noninteractive
    
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras 2>/dev/null || true
    
    echo -e "${YELLOW}🧹 Removing orphan packages...${NC}"
    sudo apt-get autoremove -y 2>/dev/null || true
    
    echo -e "${YELLOW}🔑 Removing GPG key and repository...${NC}"
    sudo rm -f /etc/apt/keyrings/docker.gpg
    sudo rm -f /etc/apt/sources.list.d/docker.list
    
    sudo apt-get update 2>/dev/null || true
}

# Function to uninstall packages on Fedora/RHEL/CentOS
uninstall_docker_rhel() {
    echo -e "${YELLOW}📦 Uninstalling Docker packages...${NC}"
    
    sudo dnf remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras 2>/dev/null || \
    sudo yum remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras 2>/dev/null || true
}

# Function to remove directories and configurations
remove_docker_files() {
    echo -e "${YELLOW}📁 Removing Docker directories...${NC}"
    
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    sudo rm -rf /etc/docker
    rm -rf ~/.docker
    
    echo -e "${GREEN}   ✓ Directories removed${NC}"
}

# Function to remove user from docker group
remove_user_from_group() {
    echo -e "${YELLOW}👤 Removing user from docker group...${NC}"
    
    if getent group docker &>/dev/null; then
        sudo gpasswd -d $USER docker 2>/dev/null || true
        echo -e "${GREEN}   ✓ User removed from docker group${NC}"
    else
        echo -e "${YELLOW}   (docker group does not exist)${NC}"
    fi
}

# Main execution
main() {
    check_privileges
    detect_distro
    
    # Check if installed
    if ! check_docker_installed; then
        exit 0
    fi
    
    # Confirm uninstallation
    confirm_uninstall
    
    echo ""
    echo -e "${CYAN}🐳 Starting Docker Engine uninstallation...${NC}"
    echo ""
    
    # Clean Docker data
    cleanup_docker_data
    
    # Stop services
    stop_docker
    
    # Uninstall based on distribution
    case $DISTRO in
        ubuntu|debian)
            uninstall_docker_debian
            ;;
        fedora|rhel|centos)
            uninstall_docker_rhel
            ;;
        *)
            echo -e "${YELLOW}⚠️  Distribution '$DISTRO' not recognized, trying generic methods...${NC}"
            uninstall_docker_debian 2>/dev/null || uninstall_docker_rhel 2>/dev/null || true
            ;;
    esac
    
    # Remove directories
    remove_docker_files
    
    # Remove user from group
    remove_user_from_group
    
    echo ""
    echo -e "${GREEN}✅ Docker Engine uninstalled successfully!${NC}"
    echo ""
    echo -e "${CYAN}📋 What was removed:${NC}"
    echo -e "${WHITE}   • Docker Engine and all components${NC}"
    echo -e "${WHITE}   • All images, containers and volumes${NC}"
    echo -e "${WHITE}   • Configurations and GPG keys${NC}"
    echo ""
    echo -e "${CYAN}💡 To reinstall, run: ./install-docker.sh${NC}"
}

# Execute
main "$@"
