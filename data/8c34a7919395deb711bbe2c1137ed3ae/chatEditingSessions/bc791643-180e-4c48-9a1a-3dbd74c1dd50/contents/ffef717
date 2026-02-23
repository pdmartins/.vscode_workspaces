# 🔷 Azure DevOps Scripts

Scripts for Azure DevOps automation. Copy to the folder where you want to clone the repositories.

## 📋 Available Scripts

### `clone-devops-repos.ps1` / `clone-devops-repos.sh`

Clone all repositories from an Azure DevOps project.

**Features:**
- 📦 Lists all repositories in a project
- 🔄 Clones new repositories automatically
- 🔄 Updates existing repositories (git pull)
- 📁 Supports JSON configuration file
- ✅ Idempotent (can run multiple times)

## 🚀 How to Use

### 1. Copy to destination folder

Copy the files to the folder where you want to clone the repositories:
```bash
cp clone-devops-repos.sh devops-config.example.json ~/projects/my-org/
cd ~/projects/my-org/
```

### 2. Configure credentials

```bash
cp config.example.json config.json
# Edit with your credentials
```

### 3. Execute

```bash
# Linux
./clone-devops-repos.sh

# Windows
.\clone-devops-repos.ps1
```

## ⚙️ Configuration

### Configuration file (`config.json`)

```json
{
  "organization_url": "https://dev.azure.com/your-org",
  "project": "project-name",
  "username": "your-email@example.com",
  "pat": "your-personal-access-token",
  "clone_path": "./repos"
}
```

### Command line parameters

| Parameter | Description |
|-----------|-------------|
| `-o`, `--org` | Azure DevOps organization URL |
| `-p`, `--project` | Project name |
| `-u`, `--username` | Username (email) |
| `-t`, `--pat` | Personal Access Token |
| `-d`, `--destination` | Destination folder (default: `./repos`) |
| `-c`, `--config` | JSON configuration file |

**Example with parameters:**
```bash
./clone-devops-repos.sh -o "https://dev.azure.com/my-org" -p "my-project" -u "email@example.com" -t "my-token"
```

## 🔑 How to get the Personal Access Token (PAT)

1. Go to Azure DevOps → ⚙️ User Settings → Personal Access Tokens
2. Click **"+ New Token"**
3. Configure:
   - **Name**: Descriptive name (e.g., "Clone Repos Script")
   - **Expiration**: Choose the period
   - **Scopes**: Select `Code (Read)` at minimum
4. Click **Create** and copy the generated token

> ⚠️ **Important:** Store the token in a safe place. It cannot be viewed again.

## 📋 Requirements

### Linux
- `git`
- `curl`
- `jq` (install with: `sudo apt install jq`)

### Windows
- `git`
- PowerShell 5.1+ or PowerShell Core
