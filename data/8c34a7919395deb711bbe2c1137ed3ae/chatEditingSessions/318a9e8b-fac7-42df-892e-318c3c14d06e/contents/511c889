#!/bin/bash
# Script to install custom Oh My Posh theme on Ubuntu
# Author: GitHub Copilot
# Date: 2026-01-15

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🎨 Installing custom Oh My Posh theme...${NC}"

# Check if Oh My Posh is installed
echo -e "${YELLOW}🔍 Checking Oh My Posh installation...${NC}"

if ! command -v oh-my-posh &> /dev/null; then
    echo -e "${RED}❌ Oh My Posh is not installed!${NC}"
    echo -e "${YELLOW}📦 Installing Oh My Posh...${NC}"
    
    # Install Oh My Posh via curl (official method)
    if curl -s https://ohmyposh.dev/install.sh | bash -s; then
        echo -e "${GREEN}✅ Oh My Posh installed successfully!${NC}"
        
        # Add to PATH if needed
        if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
            export PATH=$PATH:/usr/local/bin
        fi
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            export PATH=$PATH:$HOME/.local/bin
        fi
        
        echo -e "${CYAN}💡 You may need to restart the terminal to use Oh My Posh${NC}"
    else
        echo -e "${RED}❌ Error installing Oh My Posh${NC}"
        echo -e "${YELLOW}💡 Try installing manually: curl -s https://ohmyposh.dev/install.sh | bash -s${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Oh My Posh is already installed${NC}"
    echo -e "${YELLOW}🔄 Updating Oh My Posh...${NC}"
    
    if sudo oh-my-posh upgrade --force; then
        echo -e "${GREEN}✅ Oh My Posh updated successfully!${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not update, but continuing with current version${NC}"
    fi
fi

# Script directory (where the local theme is)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_THEME_FILE="${SCRIPT_DIR}/blocks.emoji.omp.json"

# Oh My Posh themes directory
THEMES_PATH="${HOME}/.poshthemes"

# Theme file name
THEME_NAME="blocks.emoji.omp.json"
THEME_FILE_PATH="${THEMES_PATH}/${THEME_NAME}"

echo -e "${YELLOW}📁 Themes directory: ${THEMES_PATH}${NC}"

# Create directory if it doesn't exist
if [ ! -d "$THEMES_PATH" ]; then
    echo -e "${YELLOW}📂 Creating themes directory...${NC}"
    mkdir -p "$THEMES_PATH"
fi

# Copy local theme
if [ -f "$LOCAL_THEME_FILE" ]; then
    echo -e "${YELLOW}📋 Copying local theme...${NC}"
    if cp "$LOCAL_THEME_FILE" "$THEME_FILE_PATH"; then
        echo -e "${GREEN}✅ Theme copied successfully: ${THEME_FILE_PATH}${NC}"
    else
        echo -e "${RED}❌ Error copying theme${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Theme file not found: ${LOCAL_THEME_FILE}${NC}"
    echo -e "${YELLOW}💡 Make sure to run the script from the correct directory${NC}"
    exit 1
fi

# Detect shell (bash or zsh)
SHELL_NAME=$(basename "$SHELL")
if [ "$SHELL_NAME" = "zsh" ]; then
    PROFILE_FILE="${HOME}/.zshrc"
    INIT_COMMAND="eval \"\$(oh-my-posh init zsh --config ${THEME_FILE_PATH})\""
else
    PROFILE_FILE="${HOME}/.bashrc"
    INIT_COMMAND="eval \"\$(oh-my-posh init bash --config ${THEME_FILE_PATH})\""
fi

echo -e "${YELLOW}📝 Configuring profile: ${PROFILE_FILE}${NC}"

# Create profile if it doesn't exist
if [ ! -f "$PROFILE_FILE" ]; then
    echo -e "${YELLOW}📝 Creating profile file...${NC}"
    touch "$PROFILE_FILE"
fi

# Detect where Oh My Posh is installed
OMP_INSTALL_DIR=""
if [ -f "${HOME}/.local/bin/oh-my-posh" ]; then
    OMP_INSTALL_DIR="${HOME}/.local/bin"
elif [ -f "/usr/local/bin/oh-my-posh" ]; then
    OMP_INSTALL_DIR="/usr/local/bin"
fi

# Command to add to PATH (if needed)
PATH_COMMAND=""
if [ -n "$OMP_INSTALL_DIR" ] && [ "$OMP_INSTALL_DIR" = "${HOME}/.local/bin" ]; then
    PATH_COMMAND="export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# Check if Oh My Posh configuration already exists
if grep -q "oh-my-posh init" "$PROFILE_FILE"; then
    echo -e "${YELLOW}🔄 Updating existing Oh My Posh configuration in profile...${NC}"
    
    # Remove old oh-my-posh lines
    sed -i '/oh-my-posh init/d' "$PROFILE_FILE"
    
    # Add PATH if needed and not already present
    if [ -n "$PATH_COMMAND" ] && ! grep -q '\.local/bin' "$PROFILE_FILE"; then
        echo -e "${YELLOW}📍 Adding ~/.local/bin to PATH...${NC}"
        echo "" >> "$PROFILE_FILE"
        echo "# Oh My Posh - PATH" >> "$PROFILE_FILE"
        echo "$PATH_COMMAND" >> "$PROFILE_FILE"
    fi
    
    # Add new configuration
    echo "$INIT_COMMAND" >> "$PROFILE_FILE"
    
    echo -e "${GREEN}✅ Oh My Posh configuration updated in profile${NC}"
else
    echo -e "${YELLOW}➕ Adding Oh My Posh to profile...${NC}"
    
    # Add blank line if file is not empty
    if [ -s "$PROFILE_FILE" ]; then
        echo "" >> "$PROFILE_FILE"
    fi
    
    # Add PATH if needed and not already present
    if [ -n "$PATH_COMMAND" ] && ! grep -q '\.local/bin' "$PROFILE_FILE"; then
        echo -e "${YELLOW}📍 Adding ~/.local/bin to PATH...${NC}"
        echo "# Oh My Posh - PATH" >> "$PROFILE_FILE"
        echo "$PATH_COMMAND" >> "$PROFILE_FILE"
        echo "" >> "$PROFILE_FILE"
    fi
    
    # Add configuration
    echo "# Oh My Posh - Theme" >> "$PROFILE_FILE"
    echo "$INIT_COMMAND" >> "$PROFILE_FILE"
    
    echo -e "${GREEN}✅ Oh My Posh added to profile${NC}"
fi

echo -e "\n${GREEN}✨ Installation complete!${NC}"
echo -e "${CYAN}📋 To apply the changes, run:${NC}"
echo -e "   ${NC}source ${PROFILE_FILE}${NC}"
echo -e "\n${CYAN}💡 Or close and reopen the terminal${NC}"
