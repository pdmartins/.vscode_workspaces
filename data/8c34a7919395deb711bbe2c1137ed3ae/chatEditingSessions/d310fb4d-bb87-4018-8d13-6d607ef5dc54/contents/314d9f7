# Project Context

Contexto atual do projeto para referência do Copilot.

---

## Objetivo

Scripts utilitários de automação para setup de ambiente de desenvolvimento.
Foco em idempotência, portabilidade e bilinguismo (PT/EN).

## Stack

| Componente | Tecnologia |
|------------|------------|
| Scripts Linux | Bash |
| Scripts Windows | PowerShell |
| Versionamento | Git |
| CI/CD | Planejado (não implementado) |

## Restrições

<constraints>
  - **Idioma**: Chat em PT-BR, código em EN
  - **Portabilidade**: Todo script deve ter versão Linux E Windows
  - **Bilinguismo**: `.english-version/` espelha raiz
  - **Segurança**: Sem senhas, tokens, paths absolutos
  - **Idempotência**: Scripts devem verificar estado antes de alterar
</constraints>

## Integrações

| Sistema | Propósito | Status |
|---------|-----------|--------|
| Oh My Posh | Customização de terminal | ✅ Implementado |
| Docker | Containerização | ✅ Implementado |
| Azure CLI | Recursos Azure | ✅ Parcial (só Windows) |
| Azure DevOps | DevOps CLI | ✅ Implementado |
| SSH | Geração de chaves | ✅ Implementado |

## Arquitetura de Prompts

<prompt-architecture>
  ```
  .github/
  ├── instructions/
  │   └── default.instructions.md   # Agregador
  └── .copilot/
      ├── core/                     # 🔗 Submodule (reutilizável)
      ├── project/                  # 🔗 Submodule (específico)
      └── memory/                   # Local (não é submodule)
  ```
</prompt-architecture>

## Decisões Ativas

<active-decisions>
  <decision ref="2026-02-01">
    Separação core (genérico) vs project (específico) com submodules
  </decision>
  
  <decision ref="2026-01-31">
    Skills carregados sob demanda via mandatos explícitos
  </decision>
  
  <decision ref="2026-01-31">
    Workflow Engine com tags XML para controle de fluxo
  </decision>
</active-decisions>

## Última Atualização

**Data**: 2026-02-01
**Motivo**: Reestruturação para separar core vs project
