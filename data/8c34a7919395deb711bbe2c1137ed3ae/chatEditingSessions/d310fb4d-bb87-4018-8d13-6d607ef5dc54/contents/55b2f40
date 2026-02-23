# README Instructions

<skill id="readme" context="README.md files">

<workflow id="readme-workflow" extends="workflow-engine">
  <require>core/workflow-engine.md</require>
  
  <step n="1" goal="Determinar contexto do README">
    <action>Identificar pasta do README</action>
    <action>Listar scripts existentes na pasta</action>
    <action>Identificar parâmetros de cada script</action>
  </step>

  <step n="2" goal="Verificar estrutura obrigatória">
    <validate condition="título corresponde ao nome da pasta">
      <action if="false">Corrigir título</action>
    </validate>
    
    <validate condition="seção Scripts existe">
      <action if="false">Adicionar tabela de scripts</action>
    </validate>
    
    <validate condition="seção Requisitos existe">
      <action if="false">Adicionar requisitos</action>
    </validate>
    
    <validate condition="seção Uso existe">
      <action if="false">Adicionar exemplos de uso</action>
    </validate>
  </step>

  <step n="3" goal="Sincronizar com scripts">
    <action>Verificar se todos os scripts estão documentados</action>
    <action>Verificar se parâmetros estão atualizados</action>
    <action>Verificar se exemplos refletem funcionalidade atual</action>
  </step>

  <step n="4" goal="Garantir versão em inglês">
    <check if="README está na raiz de pasta de scripts">
      <validate condition="existe versão em .english-version/">
        <action if="false">Criar versão traduzida</action>
      </validate>
    </check>
  </step>
</workflow>

## Template Obrigatório

```markdown
# {Nome da Pasta}

{Descrição breve do propósito dos scripts nesta pasta.}

## Scripts

| Script | Descrição |
|--------|-----------|
| `script.ps1` | {O que o script faz} |
| `script.sh` | {O que o script faz} |

## Requisitos

- {Requisito 1}
- {Requisito 2}

## Uso

### PowerShell

\`\`\`powershell
.\script.ps1 [-Param valor]
\`\`\`

### Bash

\`\`\`bash
./script.sh [param]
\`\`\`

## Parâmetros

| Parâmetro | Obrigatório | Descrição | Padrão |
|-----------|-------------|-----------|--------|
| `-Param` / `--param` | Não | {Descrição} | {valor} |

## Exemplos

### Uso básico

\`\`\`powershell
.\script.ps1
\`\`\`

\`\`\`bash
./script.sh
\`\`\`

### Com parâmetros

\`\`\`powershell
.\script.ps1 -Param "valor"
\`\`\`

\`\`\`bash
./script.sh --param "valor"
\`\`\`
```

## Regras

<rules>
  <rule id="sync-english">
    Sempre manter sincronizado com `.english-version/{pasta}/README.md`
  </rule>
  
  <rule id="update-on-change">
    Atualizar quando scripts forem alterados:
    - Novos parâmetros adicionados
    - Comportamento modificado
    - Novos requisitos
    - Scripts adicionados/removidos
  </rule>
  
  <rule id="examples">
    Exemplos devem ser:
    - Práticos e copiáveis (prontos para executar)
    - Cobrir casos comuns de uso
    - Mostrar tanto PS1 quanto SH quando ambos existem
  </rule>
  
  <rule id="params-table">
    Tabela de parâmetros deve incluir:
    - Nome do parâmetro (PS1 e Bash se diferentes)
    - Se é obrigatório
    - Descrição clara
    - Valor padrão se houver
  </rule>
</rules>

## Checklist de Validação

<checklist>
  <item>[ ] Título corresponde ao nome da pasta</item>
  <item>[ ] Descrição clara e concisa</item>
  <item>[ ] Tabela de scripts atualizada</item>
  <item>[ ] Requisitos listados</item>
  <item>[ ] Exemplos de uso para PS1 e SH</item>
  <item>[ ] Parâmetros documentados</item>
  <item>[ ] Versão EN sincronizada</item>
</checklist>
