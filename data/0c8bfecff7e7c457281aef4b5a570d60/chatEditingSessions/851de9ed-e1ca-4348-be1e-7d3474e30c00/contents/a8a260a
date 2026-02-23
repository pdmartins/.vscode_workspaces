#!/bin/bash
# Script to install Docker Engine on Linux (Ubuntu/Debian)
# Author: GitHub Copilot
# Date: 2026-01-30
# Note: This script installs Docker Engine, not Docker Desktop

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🐳 Installing Docker Engine...${NC}"

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
        DISTRO_VERSION=$VERSION_CODENAME
        echo -e "${GREEN}✅ Distribution detected: $DISTRO ($DISTRO_VERSION)${NC}"
    else
        echo -e "${RED}❌ Could not detect the Linux distribution${NC}"
        exit 1
    fi
}

# Function to check if Docker is already installed
check_docker_installed() {
    if command -v docker &>/dev/null; then
        DOCKER_VERSION=$(docker --version 2>/dev/null)
        echo -e "${GREEN}✅ Docker is already installed: $DOCKER_VERSION${NC}"
        
        # Check if the service is running
        if docker info &>/dev/null; then
            echo -e "${GREEN}✅ Docker is running!${NC}"
        else
            echo -e "${YELLOW}⚠️  Docker is installed but not running.${NC}"
            echo -e "${YELLOW}🔄 Starting Docker service...${NC}"
            
            if sudo systemctl start docker 2>/dev/null || sudo service docker start 2>/dev/null; then
                echo -e "${GREEN}✅ Docker service started successfully!${NC}"
            else
                echo -e "${RED}❌ Error starting Docker service${NC}"
                return 1
            fi
        fi
        
        # Check if user is in docker group
        if groups | grep -q docker; then
            echo -e "${GREEN}✅ User is already in docker group${NC}"
        else
            echo -e "${YELLOW}⚠️  User is not in docker group${NC}"
            echo -e "${YELLOW}👤 Adding user to docker group...${NC}"
            sudo usermod -aG docker $USER
            echo -e "${CYAN}💡 Logout and login again to apply the changes${NC}"
        fi
        
        return 0
    fi
    return 1
}

# Function to remove old versions
remove_old_versions() {
    echo -e "${YELLOW}🧹 Removing old Docker versions (if any)...${NC}"
    
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        sudo apt-get remove -y $pkg 2>/dev/null || true
    done
}

# Function to install Docker on Ubuntu/Debian
install_docker_debian() {
    echo -e "${YELLOW}📦 Updating package list...${NC}"
    sudo apt-get update
    
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    sudo apt-get install -y ca-certificates curl gnupg
    
    echo -e "${YELLOW}🔑 Adding Docker GPG key...${NC}"
    sudo install -m 0755 -d /etc/apt/keyrings
    
    # Determine the correct URL based on distro
    local docker_url="https://download.docker.com/linux/$DISTRO"
    
    curl -fsSL "$docker_url/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    echo -e "${YELLOW}📋 Adding Docker repository...${NC}"
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] $docker_url \
        $DISTRO_VERSION stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    echo -e "${YELLOW}📦 Installing Docker Engine...${NC}"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# Function to install Docker on Fedora/RHEL/CentOS
install_docker_rhel() {
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    sudo dnf -y install dnf-plugins-core
    
    echo -e "${YELLOW}📋 Adding Docker repository...${NC}"
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    
    echo -e "${YELLOW}📦 Installing Docker Engine...${NC}"
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# Function to configure Docker post-installation
configure_docker() {
    echo -e "${YELLOW}👤 Adding user to docker group...${NC}"
    sudo usermod -aG docker $USER
    
    echo -e "${YELLOW}🔧 Enabling Docker to start on boot...${NC}"
    if command -v systemctl &>/dev/null; then
        sudo systemctl enable docker.service
        sudo systemctl enable containerd.service
    fi
    
    echo -e "${YELLOW}🚀 Starting Docker service...${NC}"
    if command -v systemctl &>/dev/null; then
        sudo systemctl start docker
    else
        sudo service docker start
    fi
}

# Function to verify installation
verify_installation() {
    echo -e "${YELLOW}🔍 Verifying installation...${NC}"
    
    # Use sudo for the test since user needs to logout/login for docker group
    if sudo docker run --rm hello-world; then
        echo -e "${GREEN}✅ Docker Engine installed successfully!${NC}"
        return 0
    else
        echo -e "${RED}❌ Error verifying Docker${NC}"
        return 1
    fi
}

# Main execution
main() {
    check_privileges
    detect_distro
    
    # Check if already installed
    if check_docker_installed; then
        echo -e "${GREEN}🎉 Docker is already configured and working!${NC}"
        exit 0
    fi
    
    echo -e "${YELLOW}📦 Starting Docker Engine installation...${NC}"
    
    # Remove old versions
    remove_old_versions
    
    # Install based on distribution
    case $DISTRO in
        ubuntu|debian)
            install_docker_debian
            ;;
        fedora|rhel|centos)
            install_docker_rhel
            ;;
        *)
            echo -e "${RED}❌ Distribution '$DISTRO' not automatically supported${NC}"
            echo -e "${YELLOW}💡 See: https://docs.docker.com/engine/install/${NC}"
            exit 1
            ;;
    esac
    
    # Post-installation configuration
    configure_docker
    
    # Verify installation
    verify_installation
    
    echo ""
    echo -e "${GREEN}✅ Docker Engine installed successfully!${NC}"
    echo ""
    echo -e "${CYAN}📋 Next steps:${NC}"
    echo -e "${WHITE}   • Logout and login again to use docker without sudo${NC}"
    echo -e "${WHITE}   • Or run: newgrp docker${NC}"
    echo ""
    echo -e "${CYAN}💡 Useful commands:${NC}"
    echo -e "${WHITE}   • docker --version     - Check version${NC}"
    echo -e "${WHITE}   • docker ps            - List containers${NC}"
    echo -e "${WHITE}   • docker compose       - Manage multi-containers${NC}"
}

# Run
main "$@"
