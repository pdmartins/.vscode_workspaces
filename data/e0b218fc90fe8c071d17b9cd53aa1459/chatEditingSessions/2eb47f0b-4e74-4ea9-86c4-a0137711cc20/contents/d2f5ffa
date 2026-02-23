---
applyTo: '**/*.ps1,**/*.sh'
---
# Sync Rules - Regras de Sincronização

## Fluxo de Sincronização

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Script PT  │ ──► │  Script EN  │     │   README    │
│  (ps1/sh)   │     │  (english)  │     │  (PT + EN)  │
└─────────────┘     └─────────────┘     └─────────────┘
       │                                       ▲
       │            ┌─────────────┐            │
       └──────────► │  Contraparte│ ───────────┘
                    │  (sh/ps1)   │  (se houver mudança funcional)
                    └─────────────┘
```

## Regras

<sync-rule id="cross-script">
  <trigger>Alteração em *.ps1 ou *.sh</trigger>
  <action>
    1. Verificar se existe contraparte (.ps1 ↔ .sh)
    2. Se existir e NÃO estiver na lista de exceções → sincronizar
    3. Se mudança funcional (params, output, lógica) → atualizar README
  </action>
</sync-rule>

<sync-rule id="english-version">
  <trigger>Qualquer alteração em script/README na raiz</trigger>
  <action>Replicar alteração em `.english-version/` com textos traduzidos</action>
</sync-rule>

<sync-rule id="readme-update">
  <trigger>Mudança em: parâmetros, saída, comportamento, requisitos</trigger>
  <action>Atualizar README.md da pasta (PT e EN)</action>
</sync-rule>

## Exceções de Sincronização PS1 ↔ SH

<exceptions>
  <folder name="docker">
    <reason>PS1 é wrapper que chama o SH via WSL</reason>
    <sync>false</sync>
  </folder>
  
  <folder name="azure">
    <reason>Scripts específicos para Windows/PowerShell</reason>
    <sync>false</sync>
  </folder>
</exceptions>

## Checklist de Sincronização

<checklist context="após-alteração">
  <item check="contraparte">
    Existe .ps1/.sh correspondente? 
    → Se sim e não é exceção: sincronizar lógica
  </item>
  <item check="funcional">
    Mudou parâmetros/saída/comportamento?
    → Se sim: atualizar README (PT e EN)
  </item>
  <item check="english">
    Alterou arquivo na raiz?
    → Replicar em .english-version/
  </item>
</checklist>

## Como Verificar Necessidade de Sync

```
Pasta alterada está em <exceptions>?
├── SIM → Não sincronizar ps1↔sh
└── NÃO → Verificar se existe contraparte
          ├── EXISTE → Sincronizar lógica
          └── NÃO EXISTE → Apenas versão EN + README se necessário
```
