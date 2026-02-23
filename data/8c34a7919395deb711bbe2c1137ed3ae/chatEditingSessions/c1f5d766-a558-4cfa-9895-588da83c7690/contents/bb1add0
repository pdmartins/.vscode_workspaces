# Git

Scripts para gerenciamento e exportação de repositórios Git.

## Scripts

| Script | Descrição |
|--------|-----------|
| `export-git-repos.ps1` | Procura repos Git e gera script para clonar a estrutura |
| `export-git-repos.sh` | Procura repos Git e gera script para clonar a estrutura |

## Requisitos

- Git instalado e acessível no PATH
- Acesso de leitura às pastas que serão escaneadas

## Uso

### PowerShell

```powershell
.\export-git-repos.ps1 [-Path <caminho>] [-Output <arquivo>]
```

### Bash

```bash
./export-git-repos.sh [-p|--path <caminho>] [-o|--output <arquivo>]
```

## Parâmetros

| Parâmetro | Obrigatório | Descrição | Padrão |
|-----------|-------------|-----------|--------|
| `-Path` / `-p` | Não | Pasta raiz para buscar repos | Diretório atual |
| `-Output` / `-o` | Não | Arquivo de saída para o script | `clone-repos.{ps1\|sh}` |

## O que o script faz

1. **Busca recursiva**: Procura todas as pastas `.git` dentro da pasta especificada
2. **Coleta informações**: Para cada repo, obtém:
   - URL do remote `origin`
   - Branch atual
   - Caminho relativo à pasta de busca
3. **Gera script de clonagem**: Cria um script executável que pode ser usado para replicar a estrutura

## Exemplos

### Uso interativo

```powershell
.\export-git-repos.ps1
```

```bash
./export-git-repos.sh
```

O script perguntará a pasta de busca e o nome do arquivo de saída.

### Com parâmetros

```powershell
# Exportar repos da pasta Projetos
.\export-git-repos.ps1 -Path C:\Users\user\Projetos -Output meus-repos.ps1
```

```bash
# Exportar repos da pasta ~/projetos
./export-git-repos.sh -p ~/projetos -o meus-repos.sh
```

### Usando o script gerado

O script de clonagem gerado pode ser usado assim:

```powershell
# Clonar para pasta atual
.\clone-repos.ps1

# Clonar para pasta específica
.\clone-repos.ps1 -BaseDir D:\NovosProjetos
```

```bash
# Clonar para pasta atual
./clone-repos.sh

# Clonar para pasta específica
./clone-repos.sh ~/novos-projetos
```

## Observações

- Repos locais (sem remote origin) são ignorados com aviso
- O script gerado é idempotente: não clona repos que já existem
- Se a branch especificada não existir no remote, usa a branch padrão
- A estrutura de pastas original é preservada
