# 🔷 Azure DevOps Scripts

Scripts para automação do Azure DevOps. Copie para a pasta onde deseja clonar os repositórios.

## 📋 Scripts Disponíveis

### `clone-devops-repos.ps1` / `clone-devops-repos.sh`

Clona todos os repositórios de um projeto no Azure DevOps.

**Funcionalidades:**
- 📦 Lista todos os repositórios de um projeto
- 🔄 Clona novos repositórios automaticamente
- 🔄 Atualiza repositórios já existentes (git pull)
- 📁 Suporta arquivo de configuração JSON
- ✅ Idempotente (pode executar várias vezes)

## 🚀 Como Usar

### 1. Copiar para pasta de destino

Copie os arquivos para a pasta onde deseja clonar os repositórios:
```bash
cp clone-devops-repos.sh devops-config.example.json ~/projetos/minha-org/
cd ~/projetos/minha-org/
```

### 2. Configurar credenciais

```bash
cp config.example.json config.json
# Edite com suas credenciais
```

### 3. Executar

```bash
# Linux
./clone-devops-repos.sh

# Windows
.\clone-devops-repos.ps1
```

## ⚙️ Configuração

### Arquivo de configuração (`config.json`)

```json
{
  "organization_url": "https://dev.azure.com/sua-org",
  "project": "nome-do-projeto",
  "username": "seu-email@exemplo.com",
  "pat": "seu-personal-access-token",
  "clone_path": "./repos"
}
```

### Parâmetros via linha de comando

| Parâmetro | Descrição |
|-----------|-----------|
| `-o`, `--org` | URL da organização Azure DevOps |
| `-p`, `--project` | Nome do projeto |
| `-u`, `--username` | Nome de usuário (e-mail) |
| `-t`, `--pat` | Personal Access Token |
| `-d`, `--destination` | Pasta de destino (padrão: `./repos`) |
| `-c`, `--config` | Arquivo de configuração JSON |

**Exemplo com parâmetros:**
```bash
./clone-devops-repos.sh -o "https://dev.azure.com/minha-org" -p "meu-projeto" -u "email@exemplo.com" -t "meu-token"
```

## 🔑 Como obter o Personal Access Token (PAT)

1. Acesse Azure DevOps → ⚙️ User Settings → Personal Access Tokens
2. Clique em **"+ New Token"**
3. Configure:
   - **Name**: Nome descritivo (ex: "Clone Repos Script")
   - **Expiration**: Escolha o período
   - **Scopes**: Selecione `Code (Read)` no mínimo
4. Clique em **Create** e copie o token gerado

> ⚠️ **Importante:** Guarde o token em local seguro. Ele não poderá ser visualizado novamente.

## 📋 Requisitos

### Linux
- `git`
- `curl`
- `jq` (instale com: `sudo apt install jq`)

### Windows
- `git`
- PowerShell 5.1+ ou PowerShell Core
