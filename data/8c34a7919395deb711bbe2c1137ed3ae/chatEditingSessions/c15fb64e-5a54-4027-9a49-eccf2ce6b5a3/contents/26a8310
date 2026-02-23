# Chrome

Scripts para configurar segurança, privacidade e extensões do Google Chrome em múltiplos perfis.

## Scripts

| Script | Descrição |
|--------|-----------|
| `configure-chrome.ps1` | Configura Chrome no Windows (inclui bloqueio de extensões) |
| `configure-chrome.sh` | Configura Chrome no Linux e macOS |
| `config.json` | Arquivo de configuração com extensões, settings e paths |

## Arquivo de Configuração

Todas as configurações estão centralizadas no arquivo `config.json`:

```json
{
  "extensions": {
    "Nome da Extensão": "id-da-extensao"
  },
  "blockedExtensions": [
    { "name": "Nome", "id": "id-da-extensao" }
  ],
  "downloadPath": {
    "windows": "D:\\.temp",
    "linux": "~/.tmp",
    "macos": "~/.tmp"
  },
  "settings": {
    "cookies": { ... },
    "tracking": { ... },
    "autofill": { ... },
    ...
  }
}
```

### Personalizando

Edite o arquivo `config.json` para:
- Adicionar ou remover extensões
- Alterar caminhos de download
- Ajustar configurações de privacidade
- Adicionar extensões à lista de bloqueio

## O que é Configurado

### 🔒 Segurança e Privacidade

| Configuração | Valor Padrão |
|--------------|--------------|
| Cookies de terceiros | Bloqueados |
| Do Not Track | Ativado |
| Telemetria/Métricas Google | Desativado |
| Safe Browsing | Modo padrão |
| Topics API | Desativado |
| Ad Measurement API | Desativado |
| FLEDGE API | Desativado |

### 📝 Autofill

| Configuração | Valor Padrão |
|--------------|--------------|
| Endereços | Desativado |
| Cartões de crédito | Desativado |
| Senhas | Desativado |

### ⚙️ Outras Configurações

| Configuração | Valor Padrão |
|--------------|--------------|
| Sugestões de pesquisa | Desativado |
| Pré-carregamento de páginas | Desativado |
| Ao iniciar | Nova aba |
| Downloads | Sempre perguntar |
| Pasta de downloads | Configurável via config.json |
| Idioma da interface | Inglês |
| Verificação ortográfica | PT-BR e EN-US |

### 🚀 Performance

| Configuração | Valor Padrão |
|--------------|--------------|
| Memory Saver | Ativado |
| Energy Saver | Ativado (na bateria) |
| Aceleração de hardware | Ativado |
| Apps em background | Desativado |

### 📦 Extensões Padrão

Configuradas no `config.json`:
- uBlock Origin
- ClearURLs
- Privacy Badger
- Decentraleyes
- HTTPS Everywhere
- Bitwarden
- Dark Reader
- Simple Translate
- Cookie AutoDelete
- Raindrop.io
- TamperMonkey
- Wappalyzer
- EditThisCookie
- Requestly

### 📥 Métodos de Instalação de Extensões

O script oferece dois métodos para instalar extensões:

#### 1. External Extensions (Recomendado)

- **Windows**: Adiciona entradas no Registry que o Chrome lê na inicialização
- **Linux/macOS**: Cria arquivos JSON que o Chrome detecta
- **Vantagem**: Funciona para TODOS os perfis automaticamente
- O Chrome mostra um popup perguntando se deseja habilitar cada extensão
- Extensões já instaladas são ignoradas (seguro executar várias vezes)

**Onde as configurações são armazenadas:**
| OS | Local |
|----|-------|
| Windows (Admin) | `HKLM:\Software\Google\Chrome\Extensions\` |
| Windows (Usuário) | `HKCU:\Software\Google\Chrome\Extensions\` |
| Linux | `/usr/share/google-chrome/extensions/` |
| macOS | `/Library/Application Support/Google/Chrome/External Extensions/` |

#### 2. Chrome Web Store (Manual)

- Abre as páginas da Web Store para cada extensão
- **Desvantagem**: Instala apenas no perfil ATIVO
- Requer clicar "Adicionar ao Chrome" para cada extensão

### 🛡️ Extensões Bloqueadas (Somente Windows)
Configuradas em `blockedExtensions` no `config.json`. Por padrão:
- Microsoft Purview (`echcggldkblhodogklpincgchnpgcdco`)

O script:
1. Remove o conteúdo da pasta da extensão
2. Bloqueia a pasta com permissão "Deny ALL" para "Everyone"

## Requisitos

### Windows
- PowerShell 5.1+
- Direitos de administrador (para bloqueio de extensões)

### Linux
- Bash 4.0+
- `jq` (instalado automaticamente se não existir)
- Chrome ou Chromium instalado

### macOS
- Bash 4.0+
- `jq` (instalado via Homebrew se não existir)
- Google Chrome instalado

## Uso

### PowerShell (Windows)

```powershell
# Executar com configuração padrão (config.json na mesma pasta)
.\configure-chrome.ps1

# Usar arquivo de configuração personalizado
.\configure-chrome.ps1 -ConfigPath "C:\path\to\config.json"

# Apenas instalar extensões (pular configurações)
.\configure-chrome.ps1 -SkipSettings

# Apenas configurar (pular extensões)
.\configure-chrome.ps1 -SkipExtensions

# Pular bloqueio de extensões
.\configure-chrome.ps1 -SkipBlockedExtensions

# Não perguntar para fechar o Chrome
.\configure-chrome.ps1 -Force
```

### Bash (Linux/macOS)

```bash
# Tornar executável (primeira vez)
chmod +x configure-chrome.sh

# Executar com configuração padrão
./configure-chrome.sh

# Usar arquivo de configuração personalizado
./configure-chrome.sh --config /path/to/config.json

# Apenas instalar extensões
./configure-chrome.sh --skip-settings

# Apenas configurar
./configure-chrome.sh --skip-extensions

# Não perguntar para fechar o Chrome
./configure-chrome.sh --force
```

## Parâmetros

### PowerShell

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `-ConfigPath` | String | Caminho para arquivo config.json personalizado |
| `-SkipExtensions` | Switch | Não abre páginas de instalação de extensões |
| `-SkipSettings` | Switch | Não modifica as preferências do Chrome |
| `-SkipBlockedExtensions` | Switch | Não bloqueia extensões da lista |
| `-Force` | Switch | Não pergunta para fechar o Chrome |

### Bash

| Parâmetro | Descrição |
|-----------|-----------|
| `--config PATH` | Caminho para arquivo config.json personalizado |
| `--skip-extensions` | Não abre páginas de instalação de extensões |
| `--skip-settings` | Não modifica as preferências do Chrome |
| `--force` | Não pergunta para fechar o Chrome |
| `-h, --help` | Mostra ajuda |

## Notas Importantes

1. **Feche o Chrome** antes de executar o script para garantir que todas as configurações sejam aplicadas.

2. **Instalação de extensões**: O script abre as páginas da Chrome Web Store. Clique em "Adicionar ao Chrome" para cada uma.

3. **Perfis detectados**: O script detecta automaticamente todos os perfis e aplica as configurações em todos.

4. **Backup**: Antes de modificar, o script cria um backup do arquivo `Preferences`.

5. **Configuração centralizada**: Edite `config.json` para personalizar extensões e configurações.

## Exemplos

### Configurar tudo em uma nova máquina

```powershell
# Windows - Execute como Administrador
.\configure-chrome.ps1
```

```bash
# Linux/macOS
./configure-chrome.sh
```

### Usar configuração personalizada

```powershell
.\configure-chrome.ps1 -ConfigPath "D:\configs\chrome-work.json"
```

```bash
./configure-chrome.sh --config ~/configs/chrome-work.json
```

### Apenas adicionar extensões

```powershell
.\configure-chrome.ps1 -SkipSettings -SkipBlockedExtensions
```

```bash
./configure-chrome.sh --skip-settings
```
