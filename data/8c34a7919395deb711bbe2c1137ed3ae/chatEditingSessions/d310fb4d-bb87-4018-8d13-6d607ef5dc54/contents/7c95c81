# Skill: Update Structure

<skill id="update-structure" context="após criar nova pasta, novo script ou novo tipo de arquivo">

## Quando Usar Este Skill

<triggers>
  - Nova pasta de scripts criada
  - Novo tipo de arquivo/extensão adicionado ao projeto
  - Nova exceção de sincronização identificada
  - Estrutura do projeto alterada significativamente
</triggers>

## Workflow

<workflow id="update-structure-workflow">
  <step n="1" goal="Identificar mudança">
    <action>Determinar o que foi alterado na estrutura</action>
    
    <check if="nova pasta criada">
      <action>Anotar: nome da pasta, descrição, plataforma, tipos de script</action>
    </check>
    
    <check if="novo tipo de script">
      <action>Anotar: extensão, descrição, skill associado (existente ou a criar)</action>
    </check>
    
    <check if="nova exceção de sync">
      <action>Anotar: pasta, motivo da exceção</action>
    </check>
  </step>

  <step n="2" goal="Atualizar project-structure.md">
    <action>Ler: {workspace}/.github/instructions/core/project-structure.md</action>
    
    <check if="nova pasta">
      <action>Adicionar entrada na tabela "Pastas de Scripts"</action>
      <action>Atualizar árvore de estrutura se necessário</action>
    </check>
    
    <check if="novo tipo de script">
      <action>Adicionar entrada na tabela "Tipos de Script Suportados"</action>
    </check>
    
    <check if="nova exceção de sync">
      <action>Adicionar entrada na tabela "Exceções de Sincronização"</action>
    </check>
    
    <action>Atualizar campo updated na metadata</action>
  </step>

  <step n="3" goal="Atualizar skills-catalog.md se necessário">
    <check if="novo tipo de script COM skill existente">
      <action>Ler: {workspace}/.github/instructions/core/skills-catalog.md</action>
      <action>Adicionar mapeamento em "Extensões → Skills"</action>
    </check>
    
    <check if="novo tipo de script SEM skill">
      <action>Adicionar à tabela "Skills Pendentes (a criar)"</action>
      <output>⚠️ Skill para extensão .{ext} não existe. Criar com: skills/create-skill.md</output>
    </check>
  </step>

  <step n="4" goal="Verificar versão inglês">
    <check if="nova pasta criada">
      <action>Criar pasta correspondente em .english-version/</action>
      <action>Criar README.md em inglês</action>
    </check>
  </step>

  <step n="5" goal="Confirmar atualizações">
    <output>
      📋 **Estrutura Atualizada**
      
      | Arquivo | Status |
      |---------|--------|
      | core/project-structure.md | {status} |
      | core/skills-catalog.md | {status} |
      | .english-version/ | {status} |
    </output>
  </step>
</workflow>

## Checklist

<checklist>
  - [ ] project-structure.md atualizado
  - [ ] skills-catalog.md atualizado (se aplicável)
  - [ ] Pasta em .english-version/ criada (se nova pasta)
  - [ ] README criado/atualizado
</checklist>

</skill>
