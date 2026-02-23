---
applyTo: '**'
---
# Workflow Execution Engine

<engine id="scripts-workflow-engine" version="1.0">
  <objective>Motor de execução de workflows para garantir que instruções condicionais sejam seguidas de forma determinística</objective>

  <llm-mandates critical="true">
    <mandate>SEMPRE leia COMPLETAMENTE os arquivos de instrução referenciados - NUNCA pule conteúdo</mandate>
    <mandate>Execute TODOS os steps em ORDEM EXATA (1, 2, 3...)</mandate>
    <mandate>Instruções são OBRIGATÓRIAS - não são sugestões</mandate>
    <mandate>NUNCA pule um step - VOCÊ é responsável pela execução de cada step</mandate>
    <mandate>Responda em Português brasileiro, código em Inglês</mandate>
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
  </validation>
</tag-reference>

## File Detection Workflow

<workflow id="file-detection" trigger="on-file-open-or-edit">
  <step n="1" goal="Detectar tipo de arquivo e carregar instruções específicas">
    <action>Identificar extensão do arquivo atual</action>
    
    <check if="arquivo é *.sh">
      <load>{workspace}/.github/instructions/bash.instructions.md</load>
      <action>Aplicar todas as regras do arquivo carregado</action>
    </check>
    
    <check if="arquivo é *.ps1">
      <load>{workspace}/.github/instructions/powershell.instructions.md</load>
      <action>Aplicar todas as regras do arquivo carregado</action>
    </check>
    
    <check if="arquivo é README.md">
      <load>{workspace}/.github/instructions/readme.instructions.md</load>
      <action>Aplicar todas as regras do arquivo carregado</action>
    </check>
  </step>

  <step n="2" goal="Verificar necessidade de sincronização">
    <check if="arquivo é *.sh OU *.ps1">
      <load>{workspace}/.github/instructions/sync.instructions.md</load>
      <action>Avaliar regras de sincronização após qualquer alteração</action>
    </check>
  </step>
</workflow>

## Script Modification Workflow

<workflow id="script-modification" trigger="on-script-edit">
  <step n="1" goal="Pré-verificação">
    <action>Ler arquivo completo para entender contexto</action>
    <action>Identificar funções, variáveis e estrutura existente</action>
  </step>

  <step n="2" goal="Aplicar mudanças">
    <action>Seguir padrões do arquivo de instrução carregado</action>
    <action>Manter consistência com código existente</action>
    <action>Preservar idempotência</action>
  </step>

  <step n="3" goal="Pós-verificação">
    <load>{workspace}/.github/instructions/sync.instructions.md</load>
    
    <check if="mudança funcional (params, output, lógica)">
      <action>Identificar arquivos que precisam sincronização</action>
      <output>📋 Arquivos para sincronizar: {lista}</output>
    </check>
  </step>

  <step n="4" goal="Executar sincronização">
    <check if="existem arquivos para sincronizar">
      <action>Sincronizar cada arquivo identificado</action>
      <action>Atualizar README se necessário</action>
      <action>Replicar para .english-version/</action>
    </check>
  </step>
</workflow>

## Validation Checklist

<workflow id="pre-commit-validation" trigger="on-task-complete">
  <step n="1" goal="Validar script criado/modificado">
    <validate condition="script é idempotente">
      <check if="false"><halt reason="Script deve verificar estado antes de alterar"/></check>
    </validate>
    
    <validate condition="verifica pré-requisitos">
      <check if="false"><halt reason="Script deve verificar dependências"/></check>
    </validate>
    
    <validate condition="usa emojis e cores consistentes">
      <check if="false"><halt reason="Seguir padrão de emojis do projeto"/></check>
    </validate>
    
    <validate condition="tem tratamento de erros">
      <check if="false"><halt reason="Adicionar try/catch ou set -e"/></check>
    </validate>
    
    <validate condition="sem dados sensíveis">
      <check if="false"><halt reason="Remover senhas, tokens, paths absolutos"/></check>
    </validate>
  </step>

  <step n="2" goal="Validar sincronização">
    <validate condition="versão EN existe">
      <check if="false"><halt reason="Criar versão em .english-version/"/></check>
    </validate>
    
    <validate condition="README atualizado">
      <check if="false"><halt reason="Atualizar README com mudanças"/></check>
    </validate>
  </step>
</workflow>
