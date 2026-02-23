#!/bin/bash
# Script para instalar tema Oh My Posh personalizado no Ubuntu
# Autor: GitHub Copilot
# Data: 2026-01-15

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🎨 Instalando tema Oh My Posh personalizado...${NC}"

# Verificar se Oh My Posh está instalado
echo -e "${YELLOW}🔍 Verificando instalação do Oh My Posh...${NC}"

if ! command -v oh-my-posh &> /dev/null; then
    echo -e "${RED}❌ Oh My Posh não está instalado!${NC}"
    echo -e "${YELLOW}📦 Instalando Oh My Posh...${NC}"
    
    # Instalar Oh My Posh via curl (método oficial)
    if curl -s https://ohmyposh.dev/install.sh | bash -s; then
        echo -e "${GREEN}✅ Oh My Posh instalado com sucesso!${NC}"
        
        # Adicionar ao PATH se necessário
        if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
            export PATH=$PATH:/usr/local/bin
        fi
        
        echo -e "${CYAN}💡 Você pode precisar reiniciar o terminal para usar o Oh My Posh${NC}"
    else
        echo -e "${RED}❌ Erro ao instalar Oh My Posh${NC}"
        echo -e "${YELLOW}💡 Tente instalar manualmente: curl -s https://ohmyposh.dev/install.sh | bash -s${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Oh My Posh já está instalado${NC}"
    echo -e "${YELLOW}🔄 Atualizando Oh My Posh...${NC}"
    
    if sudo oh-my-posh upgrade --force; then
        echo -e "${GREEN}✅ Oh My Posh atualizado com sucesso!${NC}"
    else
        echo -e "${YELLOW}⚠️  Não foi possível atualizar, mas continuando com a versão atual${NC}"
    fi
fi

# URL do tema
THEME_URL="https://raw.githubusercontent.com/pdmartins/scripts/refs/heads/main/oh-my-posh\blocks.emoji.omp.json"

# Diretório de temas do Oh My Posh
THEMES_PATH="${HOME}/.poshthemes"

# Nome do arquivo do tema
THEME_NAME="blocks.emoji.omp.json"
THEME_FILE_PATH="${THEMES_PATH}/${THEME_NAME}"

echo -e "${YELLOW}📁 Diretório de temas: ${THEMES_PATH}${NC}"

# Criar diretório se não existir
if [ ! -d "$THEMES_PATH" ]; then
    echo -e "${YELLOW}📂 Criando diretório de temas...${NC}"
    mkdir -p "$THEMES_PATH"
fi

# Baixar o tema
echo -e "${YELLOW}⬇️  Baixando tema do GitHub...${NC}"
if curl -fsSL "$THEME_URL" -o "$THEME_FILE_PATH"; then
    echo -e "${GREEN}✅ Tema baixado com sucesso: ${THEME_FILE_PATH}${NC}"
else
    echo -e "${RED}❌ Erro ao baixar o tema${NC}"
    exit 1
fi

# Detectar shell (bash ou zsh)
SHELL_NAME=$(basename "$SHELL")
if [ "$SHELL_NAME" = "zsh" ]; then
    PROFILE_FILE="${HOME}/.zshrc"
    INIT_COMMAND="eval \"\$(oh-my-posh init zsh --config ${THEME_FILE_PATH})\""
else
    PROFILE_FILE="${HOME}/.bashrc"
    INIT_COMMAND="eval \"\$(oh-my-posh init bash --config ${THEME_FILE_PATH})\""
fi

echo -e "${YELLOW}📝 Configurando profile: ${PROFILE_FILE}${NC}"

# Criar profile se não existir
if [ ! -f "$PROFILE_FILE" ]; then
    echo -e "${YELLOW}📝 Criando arquivo de profile...${NC}"
    touch "$PROFILE_FILE"
fi

# Verificar se já existe configuração do Oh My Posh
if grep -q "oh-my-posh init" "$PROFILE_FILE"; then
    echo -e "${YELLOW}🔄 Atualizando configuração existente do Oh My Posh no profile...${NC}"
    
    # Remover linhas antigas do oh-my-posh
    sed -i '/oh-my-posh init/d' "$PROFILE_FILE"
    
    # Adicionar nova configuração
    echo "$INIT_COMMAND" >> "$PROFILE_FILE"
    
    echo -e "${GREEN}✅ Configuração do Oh My Posh atualizada no profile${NC}"
else
    echo -e "${YELLOW}➕ Adicionando Oh My Posh ao profile...${NC}"
    
    # Adicionar linha em branco se o arquivo não estiver vazio
    if [ -s "$PROFILE_FILE" ]; then
        echo "" >> "$PROFILE_FILE"
    fi
    
    # Adicionar configuração
    echo "$INIT_COMMAND" >> "$PROFILE_FILE"
    
    echo -e "${GREEN}✅ Oh My Posh adicionado ao profile${NC}"
fi

echo -e "\n${GREEN}✨ Instalação concluída!${NC}"
echo -e "${CYAN}📋 Para aplicar as mudanças, execute:${NC}"
echo -e "   ${NC}source ${PROFILE_FILE}${NC}"
echo -e "\n${CYAN}💡 Ou feche e reabra o terminal${NC}"
