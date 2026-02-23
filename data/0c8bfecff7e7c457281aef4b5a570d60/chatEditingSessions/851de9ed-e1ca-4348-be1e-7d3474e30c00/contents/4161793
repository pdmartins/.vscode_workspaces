#!/bin/bash
# Script para instalar Docker Engine no Linux (Ubuntu/Debian)
# Autor: GitHub Copilot
# Data: 2026-01-30
# Nota: Este script instala o Docker Engine, não o Docker Desktop

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🐳 Instalando Docker Engine...${NC}"

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
        DISTRO_VERSION=$VERSION_CODENAME
        echo -e "${GREEN}✅ Distribuição detectada: $DISTRO ($DISTRO_VERSION)${NC}"
    else
        echo -e "${RED}❌ Não foi possível detectar a distribuição Linux${NC}"
        exit 1
    fi
}

# Função para verificar se Docker já está instalado
check_docker_installed() {
    if command -v docker &>/dev/null; then
        DOCKER_VERSION=$(docker --version 2>/dev/null)
        echo -e "${GREEN}✅ Docker já está instalado: $DOCKER_VERSION${NC}"
        
        # Verificar se o serviço está rodando
        if docker info &>/dev/null; then
            echo -e "${GREEN}✅ Docker está rodando!${NC}"
        else
            echo -e "${YELLOW}⚠️  Docker está instalado mas não está rodando.${NC}"
            echo -e "${YELLOW}🔄 Iniciando serviço Docker...${NC}"
            
            if sudo systemctl start docker 2>/dev/null || sudo service docker start 2>/dev/null; then
                echo -e "${GREEN}✅ Serviço Docker iniciado com sucesso!${NC}"
            else
                echo -e "${RED}❌ Erro ao iniciar serviço Docker${NC}"
                return 1
            fi
        fi
        
        # Verificar se o usuário está no grupo docker
        if groups | grep -q docker; then
            echo -e "${GREEN}✅ Usuário já está no grupo docker${NC}"
        else
            echo -e "${YELLOW}⚠️  Usuário não está no grupo docker${NC}"
            echo -e "${YELLOW}👤 Adicionando usuário ao grupo docker...${NC}"
            sudo usermod -aG docker $USER
            echo -e "${CYAN}💡 Faça logout e login novamente para aplicar as mudanças${NC}"
        fi
        
        return 0
    fi
    return 1
}

# Função para remover versões antigas
remove_old_versions() {
    echo -e "${YELLOW}🧹 Removendo versões antigas do Docker (se existirem)...${NC}"
    
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        sudo apt-get remove -y $pkg 2>/dev/null || true
    done
}

# Função para instalar Docker no Ubuntu/Debian
install_docker_debian() {
    echo -e "${YELLOW}📦 Atualizando lista de pacotes...${NC}"
    sudo apt-get update
    
    echo -e "${YELLOW}📦 Instalando dependências...${NC}"
    sudo apt-get install -y ca-certificates curl gnupg
    
    echo -e "${YELLOW}🔑 Adicionando chave GPG do Docker...${NC}"
    sudo install -m 0755 -d /etc/apt/keyrings
    
    # Determinar a URL correta baseada na distro
    local docker_url="https://download.docker.com/linux/$DISTRO"
    
    curl -fsSL "$docker_url/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    echo -e "${YELLOW}📋 Adicionando repositório do Docker...${NC}"
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] $docker_url \
        $DISTRO_VERSION stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    echo -e "${YELLOW}📦 Instalando Docker Engine...${NC}"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# Função para instalar Docker no Fedora/RHEL/CentOS
install_docker_rhel() {
    echo -e "${YELLOW}📦 Instalando dependências...${NC}"
    sudo dnf -y install dnf-plugins-core
    
    echo -e "${YELLOW}📋 Adicionando repositório do Docker...${NC}"
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    
    echo -e "${YELLOW}📦 Instalando Docker Engine...${NC}"
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# Função para configurar Docker pós-instalação
configure_docker() {
    echo -e "${YELLOW}👤 Adicionando usuário ao grupo docker...${NC}"
    sudo usermod -aG docker $USER
    
    echo -e "${YELLOW}🔧 Habilitando Docker para iniciar no boot...${NC}"
    if command -v systemctl &>/dev/null; then
        sudo systemctl enable docker.service
        sudo systemctl enable containerd.service
    fi
    
    echo -e "${YELLOW}🚀 Iniciando serviço Docker...${NC}"
    if command -v systemctl &>/dev/null; then
        sudo systemctl start docker
    else
        sudo service docker start
    fi
}

# Função para verificar instalação
verify_installation() {
    echo -e "${YELLOW}🔍 Verificando instalação...${NC}"
    
    # Usar sudo para o teste já que o usuário precisa fazer logout/login para grupo docker
    if sudo docker run --rm hello-world; then
        echo -e "${GREEN}✅ Docker Engine instalado com sucesso!${NC}"
        return 0
    else
        echo -e "${RED}❌ Erro na verificação do Docker${NC}"
        return 1
    fi
}

# Execução principal
main() {
    check_privileges
    detect_distro
    
    # Verificar se já está instalado
    if check_docker_installed; then
        echo -e "${GREEN}🎉 Docker já está configurado e funcionando!${NC}"
        exit 0
    fi
    
    echo -e "${YELLOW}📦 Iniciando instalação do Docker Engine...${NC}"
    
    # Remover versões antigas
    remove_old_versions
    
    # Instalar baseado na distribuição
    case $DISTRO in
        ubuntu|debian)
            install_docker_debian
            ;;
        fedora|rhel|centos)
            install_docker_rhel
            ;;
        *)
            echo -e "${RED}❌ Distribuição '$DISTRO' não suportada automaticamente${NC}"
            echo -e "${YELLOW}💡 Consulte: https://docs.docker.com/engine/install/${NC}"
            exit 1
            ;;
    esac
    
    # Configurar pós-instalação
    configure_docker
    
    # Verificar instalação
    verify_installation
    
    echo ""
    echo -e "${GREEN}✅ Docker Engine instalado com sucesso!${NC}"
    echo ""
    echo -e "${CYAN}📋 Próximos passos:${NC}"
    echo -e "${WHITE}   • Faça logout e login novamente para usar docker sem sudo${NC}"
    echo -e "${WHITE}   • Ou execute: newgrp docker${NC}"
    echo ""
    echo -e "${CYAN}💡 Comandos úteis:${NC}"
    echo -e "${WHITE}   • docker --version     - Verificar versão${NC}"
    echo -e "${WHITE}   • docker ps            - Listar containers${NC}"
    echo -e "${WHITE}   • docker compose       - Gerenciar multi-containers${NC}"
}

# Executar
main "$@"
