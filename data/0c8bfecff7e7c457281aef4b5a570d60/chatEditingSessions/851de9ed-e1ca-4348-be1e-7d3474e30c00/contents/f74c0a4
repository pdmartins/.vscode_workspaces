# 🔐 SSH Scripts

Scripts para geração e gerenciamento de chaves SSH.

## 📋 Scripts Disponíveis

### `generate-ssh-key.ps1` (Windows)

Gera chaves SSH Ed25519 no Windows.

**Funcionalidades:**
- ✅ Gera chaves SSH usando algoritmo Ed25519 (mais seguro e moderno)
- ✅ Detecta chaves existentes e oferece opções
- ✅ Exibe a chave pública para fácil cópia
- ✅ Cria o diretório `.ssh` automaticamente

**Parâmetros:**
| Parâmetro | Obrigatório | Descrição |
|-----------|-------------|-----------|
| `-Email` | Não* | Email para identificar a chave |
| `-Name` | Não* | Nome do arquivo da chave |

*Se não fornecido, será solicitado interativamente.

**Uso:**
```powershell
# Interativo
.\generate-ssh-key.ps1

# Com parâmetros
.\generate-ssh-key.ps1 -Email "seu@email.com" -Name "github"
```

**Tratamento de chaves existentes:**
Se uma chave com o mesmo nome já existir, o script oferece:
- ↩️ **ENTER** - Sobrescrever a chave existente
- ✏️ **Novo nome** - Gerar com outro nome
- ⛔ **"sair"** - Cancelar operação

---

### `generate-ssh-key.sh` (Linux/macOS)

Gera chaves SSH Ed25519 no Linux e macOS.

**Funcionalidades:**
- ✅ Gera chaves SSH usando algoritmo Ed25519
- ✅ Detecta chaves existentes e oferece opções
- ✅ Exibe a chave pública para fácil cópia
- ✅ Cria o diretório `.ssh` automaticamente

**Uso:**
```bash
# Dar permissão de execução
chmod +x generate-ssh-key.sh

# Interativo
./generate-ssh-key.sh

# Com parâmetros
./generate-ssh-key.sh "seu@email.com" "github"
```

## 💡 Após gerar a chave

1. Copie a chave pública exibida no terminal
2. Adicione no serviço desejado:
   - **GitHub**: Settings → SSH and GPG keys → New SSH key
   - **GitLab**: Preferences → SSH Keys
   - **Azure DevOps**: User settings → SSH public keys
   - **Bitbucket**: Personal settings → SSH keys

## 🔒 Sobre Ed25519

O algoritmo Ed25519 é recomendado por:
- ✅ Maior segurança que RSA
- ✅ Chaves menores e mais rápidas
- ✅ Resistente a ataques de canal lateral
