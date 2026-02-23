# Skills System

<system id="skills-system" version="1.0">
  <objective>Sistema de carregamento de skills sob demanda</objective>
  <principle>Carregar APENAS quando necessário - evitar overhead</principle>
</system>

## Skill Announcement

<skill-announcement critical="true">
  <mandate>Em TODA resposta, VOCÊ DEVE informar no início quais skills estão em uso:</mandate>
  
  <format-new>🔧 **Skill ativada**: `{nome}` (quando carregar nova skill)</format-new>
  <format-context>🔧 **Skills em uso**: `{skill1}`, `{skill2}` (quando já no contexto)</format-context>
  
  <examples>
    - Primeira vez: "🔧 **Skill ativada**: `bash`"
    - Continuação: "🔧 **Skills em uso**: `bash`, `sync`"
    - Sem skills: Não mostrar nada
  </examples>
</skill-announcement>

## Skill Deactivation

<skill-deactivation>
  <trigger>Usuário diz: "desativar skill {nome}" ou "ignorar skill {nome}"</trigger>
  <action>Parar de aplicar regras dessa skill pelo resto da conversa</action>
  <action>Remover da lista de "skills em uso"</action>
  <output>⏹️ **Skill desativada**: `{nome}`</output>
  <note>Skills desativadas ainda estão no histórico mas suas regras são IGNORADAS</note>
</skill-deactivation>

## Skill Loading Workflow

<workflow id="skill-loading" trigger="on-file-context">
  <step n="1" goal="Detectar necessidade de skill">
    <action>Identificar tipo de arquivo ou contexto</action>
    <action>Verificar se skill está mapeado</action>
  </step>

  <step n="2" goal="Carregar skill">
    <check if="skill mapeado existe">
      <action>Ler arquivo do skill COMPLETAMENTE</action>
      <action>Anunciar skill ativada</action>
      <action>Aplicar todas as regras do skill</action>
    </check>
    
    <check if="skill NÃO existe para extensão">
      <action>Carregar skill create-skill.md</action>
      <action>Seguir workflow de criação de skill</action>
    </check>
  </step>
</workflow>

## Skill Structure Template

<template id="skill-template">
```markdown
# {Nome} Skill

<skill id="{id}" context="{quando usar}">

## Quando Usar Este Skill

<triggers>
  - {trigger 1}
  - {trigger 2}
</triggers>

## Workflow

<workflow id="{id}-workflow">
  <step n="1" goal="{objetivo}">
    {ações}
  </step>
</workflow>

## Padrões

{padrões específicos}

</skill>
```
</template>

## Core Skills

<core-skills>
  | Skill | Arquivo | Propósito |
  |-------|---------|-----------|
  | project-analyzer | `skills/project-analyzer.md` | Analisar projeto e sugerir skills |
  | project-setup | `skills/project-setup.md` | Configurar submodules e estrutura |
  | create-skill | `skills/create-skill.md` | Criar novos skills |
</core-skills>
