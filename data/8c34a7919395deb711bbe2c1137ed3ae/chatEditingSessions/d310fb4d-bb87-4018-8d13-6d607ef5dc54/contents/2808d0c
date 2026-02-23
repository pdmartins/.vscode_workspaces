# Project Structure

<metadata>
  <updated>2026-02-01</updated>
  <purpose>Estrutura atual do workspace - atualizar quando criar novas pastas/scripts</purpose>
</metadata>

## Estrutura de Pastas

```
scripts/
├── .github/
│   ├── instructions/
│   │   └── default.instructions.md   # Agregador
│   └── .copilot/                      # Nossa estrutura
│       ├── core/                      # 🔗 Submodule (reutilizável)
│       ├── project/                   # 🔗 Submodule (específico scripts)
│       └── memory/                    # Local (memória do projeto)
├── .english-version/                  # Versão inglês dos scripts
├── azure/                             # Scripts Azure (Windows)
├── azure-devops/                      # Scripts Azure DevOps
├── docker/                            # Scripts Docker
├── oh-my-posh/                        # Scripts Oh My Posh
└── ssh/                               # Scripts SSH
```

## Pastas de Scripts

| Pasta | Descrição | Plataforma | Estratégia Sync |
|-------|-----------|------------|-----------------|
| azure | Automação Azure | Windows | platform-specific |
| azure-devops | Azure DevOps CLI | Cross-platform | full-sync |
| docker | Instalação Docker | Cross-platform | full-sync |
| oh-my-posh | Temas Oh My Posh | Cross-platform | full-sync |
| ssh | Geração de chaves SSH | Cross-platform | full-sync |

## Exceções de Sincronização

| Pasta | Estratégia | Motivo |
|-------|------------|--------|
| azure | platform-specific | Azure CLI tem comportamento diferente por plataforma |

## Tipos de Script Suportados

| Extensão | Linguagem | Skill |
|----------|-----------|-------|
| .sh | Bash | bash |
| .ps1 | PowerShell | powershell |
| .bat | Batch | (pendente) |

## Regras de Sincronização

<sync-rules>
  - Todo README criado/modificado → criar versão EN
  - Todo script criado/modificado → criar versão EN
  - Scripts cross-platform → manter .sh e .ps1 sincronizados
</sync-rules>
