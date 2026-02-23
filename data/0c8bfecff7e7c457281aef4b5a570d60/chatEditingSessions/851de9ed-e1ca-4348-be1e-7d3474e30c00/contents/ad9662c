# 🔐 SSH Scripts

Scripts for generating and managing SSH keys.

## 📋 Available Scripts

### `generate-ssh-key.ps1` (Windows)

Generates Ed25519 SSH keys on Windows.

**Features:**
- ✅ Generates SSH keys using Ed25519 algorithm (more secure and modern)
- ✅ Detects existing keys and offers options
- ✅ Displays the public key for easy copying
- ✅ Creates `.ssh` directory automatically

**Parameters:**
| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Email` | No* | Email to identify the key |
| `-Name` | No* | Key file name |

*If not provided, will be requested interactively.

**Usage:**
```powershell
# Interactive
.\generate-ssh-key.ps1

# With parameters
.\generate-ssh-key.ps1 -Email "your@email.com" -Name "github"
```

**Handling existing keys:**
If a key with the same name already exists, the script offers:
- ↩️ **ENTER** - Overwrite the existing key
- ✏️ **New name** - Generate with another name
- ⛔ **"exit"** - Cancel operation

---

### `generate-ssh-key.sh` (Linux/macOS)

Generates Ed25519 SSH keys on Linux and macOS.

**Features:**
- ✅ Generates SSH keys using Ed25519 algorithm
- ✅ Detects existing keys and offers options
- ✅ Displays the public key for easy copying
- ✅ Creates `.ssh` directory automatically

**Usage:**
```bash
# Give execution permission
chmod +x generate-ssh-key.sh

# Interactive
./generate-ssh-key.sh

# With parameters
./generate-ssh-key.sh "your@email.com" "github"
```

## 💡 After generating the key

1. Copy the public key displayed in the terminal
2. Add it to the desired service:
   - **GitHub**: Settings → SSH and GPG keys → New SSH key
   - **GitLab**: Preferences → SSH Keys
   - **Azure DevOps**: User settings → SSH public keys
   - **Bitbucket**: Personal settings → SSH keys

## 🔒 About Ed25519

The Ed25519 algorithm is recommended because:
- ✅ More secure than RSA
- ✅ Smaller and faster keys
- ✅ Resistant to side-channel attacks
