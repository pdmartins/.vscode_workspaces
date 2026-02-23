# VS Code Chat Sync

Sincroniza o histórico de chats do GitHub Copilot Chat entre máquinas via Git.
Suporta VS Code **Stable** e **Insiders** com chats unificados.

## Como funciona

1. Os chats ficam em `workspaceStorage/` do VS Code (Stable e/ou Insiders)
2. Este repo coleta os chats de todas as edições em uma pasta `data/` unificada
3. No pull, restaura para todas as edições ativas — Stable e Insiders veem os mesmos chats
4. File watcher + pull periódico mantém tudo sincronizado automaticamente
5. Cada workspace gera seu próprio commit: `chatsync: HOSTNAME | projeto | timestamp`

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
# Edite se necessário (paths, edições, intervalos)
```

**Configurações principais:**
- `VSCODE_EDITIONS` — Edições a sincronizar: `stable`, `insiders` ou `stable,insiders`
- `PULL_INTERVAL` — Intervalo de pull periódico (padrão: 5 min)
- `SYNC_INTERVAL` — Debounce para push (padrão: 30s)

### 3. Execute o setup

**Windows (PowerShell como Admin):**
```powershell
.\setup.ps1
```

**Linux:**
```bash
chmod +x setup.sh && ./setup.sh
```

### 4. Sync inicial

```bash
# Na primeira máquina (que já tem os chats):
./sync.sh push

# Na segunda máquina:
./sync.sh pull
```

## Comandos manuais

```bash
./sync.sh push    # Commit por workspace + push
./sync.sh pull    # Pull + restaura para todas as edições
./sync.sh status  # Mostra edições ativas, mudanças e mapeamentos
```

## Fluxo automático

1. **Liga o PC** → watcher inicia → pull automático (pega tudo do remoto)
2. **Trabalha no VS Code** → file watcher detecta mudanças → push com debounce de 30s
3. **A cada 5 min** → pull periódico (pega mudanças de outras máquinas)
4. **Troca de máquina** → mesma coisa, tudo transparente

## Conflitos Stable vs Insiders

Se você usar o Copilot Chat no **mesmo projeto** em ambas as edições, vale **last-write-wins** — o que foi modificado por último sobrescreve no push.

## Paths diferentes entre máquinas

Se os projetos estão em paths diferentes (ex: `/home/pedro` vs `C:\Users\Pedro`), use o script de remap:

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
