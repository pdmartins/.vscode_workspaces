# Workflow Execution Engine

<engine id="workflow-engine" version="2.0">
  <objective>Motor de execução de workflows determinístico e reutilizável</objective>

  <llm-mandates critical="true">
    <mandate>SEMPRE leia COMPLETAMENTE os arquivos de instrução referenciados</mandate>
    <mandate>Execute TODOS os steps em ORDEM EXATA (1, 2, 3...)</mandate>
    <mandate>Instruções são OBRIGATÓRIAS - não são sugestões</mandate>
    <mandate>NUNCA pule um step - VOCÊ é responsável pela execução de cada step</mandate>
  </llm-mandates>

  <execution-rules>
    <rule n="1">Steps executam em ordem numérica exata</rule>
    <rule n="2">Tags `check if` devem ser avaliadas como condicionais booleanas</rule>
    <rule n="3">Tags `action` são ações obrigatórias a executar</rule>
    <rule n="4">Tags `halt` interrompem execução e aguardam usuário</rule>
    <rule n="5">Tags `load` requerem leitura completa do arquivo referenciado</rule>
  </execution-rules>
</engine>

## Supported Tags

<tag-reference>
  <structural>
    <tag name="step" attrs="n, goal">Define step com número e objetivo</tag>
    <tag name="check" attrs="if">Bloco condicional - requer closing tag</tag>
    <tag name="action" attrs="if?">Ação a executar (if opcional para inline)</tag>
  </structural>
  
  <execution>
    <tag name="load">Carregar arquivo referenciado completamente</tag>
    <tag name="halt" attrs="reason">Parar execução e reportar motivo</tag>
    <tag name="goto" attrs="step">Pular para step especificado</tag>
    <tag name="output">Exibir mensagem para usuário</tag>
  </execution>
  
  <validation>
    <tag name="validate">Verificar condição antes de prosseguir</tag>
    <tag name="require">Dependência obrigatória</tag>
    <tag name="mandate">Regra obrigatória (mais forte que action)</tag>
  </validation>
  
  <metadata>
    <tag name="skill" attrs="id, context">Define um skill</tag>
    <tag name="workflow" attrs="id, trigger">Define um workflow</tag>
    <tag name="rule" attrs="id, critical?">Define uma regra</tag>
  </metadata>
</tag-reference>

## Workflow Template

<template id="workflow-template">
```xml
<workflow id="{id}" trigger="{quando-executa}">
  <step n="1" goal="{objetivo}">
    <check if="{condição}">
      <action>{ação}</action>
    </check>
  </step>
  
  <step n="2" goal="{objetivo}">
    <validate condition="{condição}">
      <halt if="false" reason="{motivo}"/>
    </validate>
  </step>
</workflow>
```
</template>
