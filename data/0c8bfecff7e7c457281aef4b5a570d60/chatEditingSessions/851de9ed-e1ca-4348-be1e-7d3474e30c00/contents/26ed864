# 🐳 Docker Scripts

Scripts para instalação do Docker Engine (não Docker Desktop).

## 📋 Scripts Disponíveis

### `install-docker.ps1` (Windows)

Instala o Docker Engine no Windows via WSL2.

**Por que WSL2?**
O Docker Engine depende de recursos do kernel Linux. No Windows 10/11, a única forma de rodar Docker Engine sem Docker Desktop é através do WSL2.

**Funcionalidades:**
- ✅ Verifica e instala WSL2 se necessário
- ✅ Verifica e instala Ubuntu se não houver distribuição Linux
- ✅ Instala Docker Engine dentro do WSL
- ✅ Configura usuário no grupo docker
- ✅ Idempotente - pode ser executado múltiplas vezes

**Requisitos:**
- Windows 10 versão 2004+ ou Windows 11
- Privilégios de administrador
- Virtualização habilitada na BIOS

**Uso:**
```powershell
# Executar como Administrador
.\install-docker.ps1
```

**Após instalação:**
```powershell
# Acessar WSL
wsl

# Usar docker normalmente
docker --version
docker run hello-world
```

---

### `install-docker.sh` (Linux)

Instala o Docker Engine em distribuições Linux.

**Distribuições suportadas:**
- ✅ Ubuntu
- ✅ Debian
- ✅ Fedora
- ✅ RHEL/CentOS

**Funcionalidades:**
- ✅ Detecta automaticamente a distribuição
- ✅ Remove versões antigas do Docker
- ✅ Instala Docker CE, CLI, containerd, buildx e compose
- ✅ Configura para iniciar no boot
- ✅ Adiciona usuário ao grupo docker
- ✅ Idempotente - pode ser executado múltiplas vezes

**Uso:**
```bash
# Dar permissão de execução
chmod +x install-docker.sh

# Executar
./install-docker.sh
# ou
sudo ./install-docker.sh
```

**Após instalação:**
```bash
# Fazer logout/login ou executar
newgrp docker

# Testar
docker --version
docker run hello-world
```

## ⚠️ Nota Importante

Estes scripts instalam o **Docker Engine** (open source), não o Docker Desktop. O Docker Desktop possui licenciamento diferente para uso comercial.
