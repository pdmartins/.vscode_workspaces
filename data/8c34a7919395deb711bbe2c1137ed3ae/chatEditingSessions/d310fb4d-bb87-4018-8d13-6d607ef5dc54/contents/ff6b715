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
| SSH | Geração de chaves | ✅ Implementado |

## Decisões Ativas

<active-decisions>
  <decision ref="lessons-learned:2026-01-31:arquitetura">
    Skills carregados sob demanda via mandatos explícitos no default.instructions.md
  </decision>
  
  <decision ref="lessons-learned:2026-01-31:arquitetura">
    Estrutura extensível com update-structure.md e create-skill.md
  </decision>
  
  <decision ref="lessons-learned:2026-01-31:arquitetura">
    Workflow Engine com tags XML para controle de fluxo
  </decision>
</active-decisions>

## Padrões de Pasta

| Pasta | Conteúdo | Estratégia Sync |
|-------|----------|-----------------|
| docker/ | Instalação Docker | full-sync |
| ssh/ | Geração de chaves | full-sync |
| oh-my-posh/ | Temas OMP | full-sync |
| azure/ | Azure CLI | platform-specific |

## Última Atualização

**Data**: 2026-01-31
**Motivo**: Criação inicial do contexto durante implementação do sistema de memória
