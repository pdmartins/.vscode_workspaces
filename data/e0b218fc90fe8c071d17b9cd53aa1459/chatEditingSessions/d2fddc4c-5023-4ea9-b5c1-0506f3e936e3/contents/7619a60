#!/bin/bash
# Script para desinstalar Docker Engine do Linux (Ubuntu/Debian/Fedora/RHEL)
# Autor: GitHub Copilot
# Data: 2026-01-30
# Nota: Este script remove completamente o Docker Engine e seus dados

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}🐳 Desinstalador do Docker Engine${NC}"

# Função para verificar se está rodando como root ou com sudo
check_privileges() {
    if [[ $EUID -ne 0 ]]; then
        if ! sudo -v &>/dev/null; then
            echo -e "${RED}❌ Este script precisa de privilégios de administrador!${NC}"
            echo -e "${YELLOW}💡 Execute com: sudo $0${NC}"
            exit 1
        fi
    fi
}

# Função para detectar a distribuição
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO=$ID
        echo -e "${GREEN}✅ Distribuição detectada: $DISTRO${NC}"
    else
        echo -e "${YELLOW}⚠️  Não foi possível detectar a distribuição, usando métodos genéricos${NC}"
        DISTRO="unknown"
    fi
}

# Função para verificar se Docker está instalado
check_docker_installed() {
    if command -v docker &>/dev/null; then
        DOCKER_VERSION=$(docker --version 2>/dev/null || echo "desconhecida")
        echo -e "${GREEN}✅ Docker encontrado: $DOCKER_VERSION${NC}"
        return 0
    else
        echo -e "${YELLOW}ℹ️  Docker não está instalado. Nada a fazer.${NC}"
        return 1
    fi
}

# Função para confirmar desinstalação (apenas em modo interativo)
confirm_uninstall() {
    # Se não for terminal interativo, pular confirmação
    if [[ ! -t 0 ]]; then
        return 0
    fi
    
    echo ""
    echo -e "${YELLOW}⚠️  ATENÇÃO: Esta ação irá remover:${NC}"
    echo -e "   • Docker Engine (docker-ce, docker-ce-cli)"
    echo -e "   • Containerd"
    echo -e "   • Docker Buildx e Compose plugins"
    echo -e "   • Todas as imagens, containers e volumes Docker"
    echo -e "   • Configurações do Docker"
    echo ""
    
    read -p "❓ Deseja continuar? (s/n): " confirm
    if [[ ! "$confirm" =~ ^[sS]$ ]]; then
        echo -e "${RED}❌ Operação cancelada pelo usuário.${NC}"
        exit 0
    fi
}

# Função para parar containers e serviço
stop_docker() {
    echo -e "${YELLOW}🛑 Parando serviço Docker...${NC}"
    
    # Tentar parar via systemctl ou service
    if command -v systemctl &>/dev/null; then
        sudo systemctl stop docker.service 2>/dev/null || true
        sudo systemctl stop docker.socket 2>/dev/null || true
        sudo systemctl stop containerd.service 2>/dev/null || true
    else
        sudo service docker stop 2>/dev/null || true
    fi
    
    # Matar processos restantes
    sudo pkill -9 dockerd 2>/dev/null || true
    sudo pkill -9 containerd 2>/dev/null || true
    
    echo -e "${GREEN}   ✓ Serviço Docker parado${NC}"
}

# Função para limpar containers, imagens e volumes
cleanup_docker_data() {
    # Verificar se docker ainda está acessível
    if ! command -v docker &>/dev/null; then
        return 0
    fi
    
    echo -e "${YELLOW}🛑 Parando todos os containers...${NC}"
    if sudo docker ps -aq 2>/dev/null | grep -q .; then
        sudo docker stop $(sudo docker ps -aq) 2>/dev/null || true
        echo -e "${GREEN}   ✓ Containers parados${NC}"
    else
        echo -e "${YELLOW}   (nenhum container encontrado)${NC}"
    fi
    
    echo -e "${YELLOW}🗑️ Removendo todos os containers...${NC}"
    if sudo docker ps -aq 2>/dev/null | grep -q .; then
        sudo docker rm -f $(sudo docker ps -aq) 2>/dev/null || true
        echo -e "${GREEN}   ✓ Containers removidos${NC}"
    else
        echo -e "${YELLOW}   (nenhum container para remover)${NC}"
    fi
    
    echo -e "${YELLOW}🗑️ Removendo todas as imagens...${NC}"
    if sudo docker images -aq 2>/dev/null | grep -q .; then
        sudo docker rmi -f $(sudo docker images -aq) 2>/dev/null || true
        echo -e "${GREEN}   ✓ Imagens removidas${NC}"
    else
        echo -e "${YELLOW}   (nenhuma imagem para remover)${NC}"
    fi
    
    echo -e "${YELLOW}🗑️ Removendo todos os volumes...${NC}"
    if sudo docker volume ls -q 2>/dev/null | grep -q .; then
        sudo docker volume rm -f $(sudo docker volume ls -q) 2>/dev/null || true
        echo -e "${GREEN}   ✓ Volumes removidos${NC}"
    else
        echo -e "${YELLOW}   (nenhum volume para remover)${NC}"
    fi
    
    echo -e "${YELLOW}🗑️ Removendo networks customizadas...${NC}"
    sudo docker network prune -f 2>/dev/null || true
    echo -e "${GREEN}   ✓ Networks removidas${NC}"
}

# Função para desinstalar pacotes no Ubuntu/Debian
uninstall_docker_debian() {
    echo -e "${YELLOW}📦 Desinstalando pacotes Docker...${NC}"
    
    # Configurar para não pedir confirmação
    export DEBIAN_FRONTEND=noninteractive
    
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras 2>/dev/null || true
    
    echo -e "${YELLOW}🧹 Removendo pacotes órfãos...${NC}"
    sudo apt-get autoremove -y 2>/dev/null || true
    
    echo -e "${YELLOW}🔑 Removendo chave GPG e repositório...${NC}"
    sudo rm -f /etc/apt/keyrings/docker.gpg
    sudo rm -f /etc/apt/sources.list.d/docker.list
    
    sudo apt-get update 2>/dev/null || true
}

# Função para desinstalar pacotes no Fedora/RHEL/CentOS
uninstall_docker_rhel() {
    echo -e "${YELLOW}📦 Desinstalando pacotes Docker...${NC}"
    
    sudo dnf remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras 2>/dev/null || \
    sudo yum remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras 2>/dev/null || true
}

# Função para remover diretórios e configurações
remove_docker_files() {
    echo -e "${YELLOW}📁 Removendo diretórios do Docker...${NC}"
    
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    sudo rm -rf /etc/docker
    rm -rf ~/.docker
    
    echo -e "${GREEN}   ✓ Diretórios removidos${NC}"
}

# Função para remover usuário do grupo docker
remove_user_from_group() {
    echo -e "${YELLOW}👤 Removendo usuário do grupo docker...${NC}"
    
    if getent group docker &>/dev/null; then
        sudo gpasswd -d $USER docker 2>/dev/null || true
        echo -e "${GREEN}   ✓ Usuário removido do grupo docker${NC}"
    else
        echo -e "${YELLOW}   (grupo docker não existe)${NC}"
    fi
}

# Execução principal
main() {
    check_privileges
    detect_distro
    
    # Verificar se está instalado
    if ! check_docker_installed; then
        exit 0
    fi
    
    # Confirmar desinstalação
    confirm_uninstall
    
    echo ""
    echo -e "${CYAN}🐳 Iniciando desinstalação do Docker Engine...${NC}"
    echo ""
    
    # Limpar dados do Docker
    cleanup_docker_data
    
    # Parar serviços
    stop_docker
    
    # Desinstalar baseado na distribuição
    case $DISTRO in
        ubuntu|debian)
            uninstall_docker_debian
            ;;
        fedora|rhel|centos)
            uninstall_docker_rhel
            ;;
        *)
            echo -e "${YELLOW}⚠️  Distribuição '$DISTRO' não reconhecida, tentando métodos genéricos...${NC}"
            uninstall_docker_debian 2>/dev/null || uninstall_docker_rhel 2>/dev/null || true
            ;;
    esac
    
    # Remover diretórios
    remove_docker_files
    
    # Remover usuário do grupo
    remove_user_from_group
    
    echo ""
    echo -e "${GREEN}✅ Docker Engine desinstalado com sucesso!${NC}"
    echo ""
    echo -e "${CYAN}📋 O que foi removido:${NC}"
    echo -e "${WHITE}   • Docker Engine e todos os componentes${NC}"
    echo -e "${WHITE}   • Todas as imagens, containers e volumes${NC}"
    echo -e "${WHITE}   • Configurações e chaves GPG${NC}"
    echo ""
    echo -e "${CYAN}💡 Para reinstalar, execute: ./install-docker.sh${NC}"
}

# Executar
main "$@"
