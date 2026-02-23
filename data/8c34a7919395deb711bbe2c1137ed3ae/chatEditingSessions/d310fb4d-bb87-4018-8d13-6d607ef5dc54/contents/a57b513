# Project Structure

<metadata>
  <updated>2026-01-31</updated>
  <purpose>Estrutura atual do workspace - atualizar quando criar novas pastas/scripts</purpose>
</metadata>

## Estrutura de Pastas

```
scripts/
├── .github/
│   ├── instructions/          # Instruções Copilot
│   │   ├── core/              # Arquivos core (sempre referenciados)
│   │   │   ├── workflow-engine.md
│   │   │   ├── project-structure.md  ← este arquivo
│   │   │   └── skills-catalog.md
│   │   ├── skills/            # Skills sob demanda
│   │   │   ├── bash.md
│   │   │   ├── powershell.md
│   │   │   ├── readme.md
│   │   │   ├── sync.md
│   │   │   ├── update-structure.md
│   │   │   └── create-skill.md
│   │   └── default.instructions.md
│   └── .memory/               # Lições aprendidas
│       └── lessons-learned.md
├── .english-version/          # Versão inglês dos scripts
├── azure/                     # Scripts Azure (Windows/PowerShell)
├── docker/                    # Scripts Docker
├── oh-my-posh/               # Scripts Oh My Posh
└── ssh/                       # Scripts SSH
```

## Pastas de Scripts

| Pasta | Descrição | Plataforma | Scripts |
|-------|-----------|------------|---------|
| azure | Automação Azure | Windows | .ps1, .bat |
| docker | Instalação/gerenciamento Docker | Cross-platform | .ps1, .sh |
| oh-my-posh | Temas e instalação OMP | Cross-platform | .ps1, .sh |
| ssh | Geração de chaves SSH | Cross-platform | .ps1, .sh |

## Tipos de Script Suportados

| Extensão | Skill | Descrição |
|----------|-------|-----------|
| .sh | bash | Scripts Bash/Shell |
| .ps1 | powershell | Scripts PowerShell |
| .bat | _(a criar)_ | Batch files Windows |

## Exceções de Sincronização PS1↔SH

| Pasta | Sincroniza? | Motivo |
|-------|-------------|--------|
| docker | ❌ | PS1 é wrapper que chama SH via WSL |
| azure | ❌ | Específico Windows/PowerShell |

## Como Atualizar Este Arquivo

<update-trigger>
  Atualizar quando:
  - Nova pasta de scripts criada
  - Novo tipo de script adicionado (nova extensão)
  - Nova exceção de sincronização identificada
</update-trigger>

<update-skill>
  Para atualizar: carregar skill `skills/update-structure.md`
</update-skill>
