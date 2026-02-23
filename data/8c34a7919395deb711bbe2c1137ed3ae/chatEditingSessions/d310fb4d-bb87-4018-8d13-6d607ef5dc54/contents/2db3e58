# Project Setup Skill

<skill id="project-setup" context="configurar submodules e estrutura de prompts">

## Propósito

Gerenciar a configuração de submodules do copilot e a estrutura de prompts em projetos.

## Quando Usar

<triggers>
  - Inicializar submodules em novo projeto
  - Atualizar submodules existentes
  - Configurar estrutura de prompts
  - Vincular project-specific submodule
</triggers>

## Workflow: Inicializar Projeto

<workflow id="init-project">
  <step n="1" goal="Verificar pré-requisitos">
    <action>Verificar se .github/ existe</action>
    <action>Verificar se git está inicializado</action>
    
    <check if=".github/.copilot/ já existe">
      <output>⚠️ Estrutura já existe. Use workflow de atualização.</output>
      <halt reason="Estrutura já configurada"/>
    </check>
  </step>

  <step n="2" goal="Criar estrutura base">
    <action>Criar pasta .github/.copilot/</action>
    <action>Criar pasta .github/.copilot/memory/</action>
    <action>Criar .github/.copilot/memory/lessons-learned.md</action>
    <action>Criar .github/.copilot/memory/project-context.md</action>
  </step>

  <step n="3" goal="Adicionar submodule core">
    <command>
      git submodule add {repo-core} .github/.copilot/core
    </command>
    
    <output>📦 Submodule core adicionado</output>
  </step>

  <step n="4" goal="Adicionar submodule project">
    <ask>Qual repositório de project usar? (ou 'novo' para criar do zero)</ask>
    
    <check if="repositório existente">
      <command>
        git submodule add {repo-project} .github/.copilot/project
      </command>
    </check>
    
    <check if="novo">
      <action>Criar estrutura project/ local</action>
      <action>Executar project-analyzer para configurar</action>
    </check>
    
    <output>📦 Submodule project configurado</output>
  </step>

  <step n="5" goal="Criar default.instructions.md">
    <action>Criar .github/instructions/default.instructions.md</action>
    <action>Configurar para carregar core e project</action>
    
    <output>✅ Projeto inicializado com sucesso</output>
  </step>
</workflow>

## Workflow: Atualizar Submodules

<workflow id="update-submodules">
  <step n="1" goal="Atualizar core">
    <command>
      cd .github/.copilot/core && git pull origin main
    </command>
    <output>🔄 Core atualizado</output>
  </step>

  <step n="2" goal="Atualizar project">
    <command>
      cd .github/.copilot/project && git pull origin main
    </command>
    <output>🔄 Project atualizado</output>
  </step>

  <step n="3" goal="Commitar atualizações">
    <command>
      git add .github/.copilot/
      git commit -m "chore: update copilot submodules"
    </command>
    <output>✅ Submodules atualizados</output>
  </step>
</workflow>

## Workflow: Criar Project Local

<workflow id="create-local-project">
  <step n="1" goal="Criar estrutura">
    <action>Criar .github/.copilot/project/initial.md</action>
    <action>Criar .github/.copilot/project/skills/</action>
  </step>

  <step n="2" goal="Executar analyzer">
    <load>project-analyzer.md</load>
    <action>Seguir workflow de análise</action>
  </step>
</workflow>

## Commands Reference

<commands>
  | Comando | Propósito |
  |---------|-----------|
  | `git submodule add {url} {path}` | Adicionar submodule |
  | `git submodule update --init --recursive` | Inicializar submodules após clone |
  | `git submodule update --remote` | Atualizar para última versão |
</commands>

</skill>
