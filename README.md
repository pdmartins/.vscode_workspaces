# VS Code Chat Sync

Sincroniza o histórico de chats do GitHub Copilot Chat entre máquinas via Git.
Suporta VS Code **Stable**, **Insiders**, **WSL** e **SSH remoto** com chats unificados.

## Como funciona

1. Os chats ficam em `workspaceStorage/` do VS Code (cada edição tem seu path)
2. Este repo coleta os chats de todas as edições em uma pasta `data/` unificada
3. No pull, restaura para todas as edições ativas — todos veem os mesmos chats
4. File watcher + pull periódico mantém tudo sincronizado automaticamente
5. Cada workspace gera seu próprio commit: `chatsync: HOSTNAME | projeto | timestamp`

## Edições suportadas

| Edição | Storage Path (Windows) | Storage Path (Linux) |
|--------|----------------------|---------------------|
| Stable | `%APPDATA%\Code\User\workspaceStorage` | `~/.config/Code/User/workspaceStorage` |
| Insiders | `%APPDATA%\Code - Insiders\User\workspaceStorage` | `~/.config/Code - Insiders/User/workspaceStorage` |
| WSL | `\\wsl$\<distro>\home\<user>\.vscode-server\...` | N/A (handled from Windows) |
| SSH | N/A (handled on remote) | `~/.vscode-server/data/User/workspaceStorage` |

## Requisitos

- Git configurado com SSH ou credential manager
- Python 3 (para resolver nomes de workspace)
- Linux: `inotify-tools` e `rsync` (instalados automaticamente pelo setup)

## Setup

### 1. Clone o repo

```bash
git clone <seu-repo-url> ~/vscode-chat-sync
```

### 2. Configure

```bash
cp .env.example .env
```

**Configurações principais:**

```bash
# Edições a sincronizar
VSCODE_EDITIONS=stable,insiders,wsl    # Windows host
VSCODE_EDITIONS=stable,ssh             # Linux / servidor SSH

# WSL (auto-detecta user se não definido)
WSL_DISTRO=Ubuntu
WSL_USER=pedro

# Pull periódico
PULL_INTERVAL=5
```

### 3. Execute o setup

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

**Linux:**
```bash
chmod +x setup.sh && ./setup.sh
```

### 4. Sync inicial

```bash
# Na primeira máquina:
./sync.sh push    # ou .\sync.ps1 push

# Nas demais:
./sync.sh pull    # ou .\sync.ps1 pull
```

## Cenários de uso

### Windows com WSL

```
VSCODE_EDITIONS=stable,insiders,wsl
WSL_DISTRO=Ubuntu
```

O watcher do Windows monitora Stable e Insiders via `FileSystemWatcher` e WSL via polling (o `FileSystemWatcher` não funciona em paths `\\wsl$`). No pull, os chats são restaurados para as três edições.

### Servidor SSH (ex: Dell Latitude como dev server)

No servidor remoto:
```bash
git clone <repo> ~/vscode-chat-sync
cp .env.example .env
# Edite: VSCODE_EDITIONS=ssh
./setup.sh
```

O watcher roda como serviço systemd no servidor, monitorando `~/.vscode-server/data/User/workspaceStorage`. Quando você usa VS Code Remote-SSH, os chats são sincronizados automaticamente.

### Múltiplas máquinas + WSL + SSH

```
Máquina A (Windows):  VSCODE_EDITIONS=stable,insiders,wsl
Máquina B (Windows):  VSCODE_EDITIONS=stable,insiders
Servidor SSH (Linux): VSCODE_EDITIONS=ssh
```

Todos compartilham o mesmo repo Git. O fluxo:
1. Trabalha na máquina A → watcher push
2. Servidor SSH faz pull periódico → chats disponíveis via Remote-SSH
3. Vai para máquina B → watcher pull na inicialização → tudo sincronizado

## Comandos manuais

```bash
./sync.sh push    # Commit por workspace + push
./sync.sh pull    # Pull + restaura para todas as edições
./sync.sh status  # Mostra edições ativas, mudanças e mapeamentos
```

## Conflitos

- **Entre edições (Stable vs Insiders vs WSL):** last-write-wins por workspace
- **Entre máquinas:** last-push-wins (Git linear history via rebase)

## Paths diferentes entre máquinas

```bash
./remap.sh "/home/pedro" "C:/Users/Pedro"
```

## Estrutura do repo

```
data/
  <workspace-hash>/
    workspace.json              # URI do projeto
    GitHub.copilot-chat/        # Dados dos chats
  _globalStorage/               # Dados globais do Copilot
```

## Troubleshooting

**WSL não detectado:** Verifique se `WSL_DISTRO` e `WSL_USER` estão corretos no `.env`, e se o path `\\wsl$\Ubuntu\...` é acessível no Windows Explorer.

**SSH não sincroniza:** Verifique se o watcher está rodando no servidor: `systemctl --user status vscode-chat-sync`

**Conflitos de Git:** Se o rebase falhar, rode `git rebase --abort` e depois `./sync.sh push` para forçar.
