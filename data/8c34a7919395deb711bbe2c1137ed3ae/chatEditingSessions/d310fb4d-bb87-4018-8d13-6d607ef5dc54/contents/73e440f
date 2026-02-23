---
applyTo: '**'
---
# Copilot Instructions - Workflow Engine

<engine-loader critical="true">
  <mandate>Este arquivo governa TODAS as operações no workspace</mandate>
  <mandate>Instruções são OBRIGATÓRIAS, não sugestões</mandate>
  <mandate>Execute workflows em ORDEM EXATA</mandate>
  <mandate>NÃO carregue todos os arquivos - carregue APENAS quando necessário</mandate>
</engine-loader>

## Regras Fundamentais

<rules critical="true">
  <rule id="language">
    <chat>Português brasileiro</chat>
    <code>Inglês (variáveis, funções, parâmetros, nomes de arquivo)</code>
  </rule>
  
  <rule id="no-auto-docs">
    NUNCA crie arquivos markdown/logs para documentar atividades automaticamente.
    Apenas crie/atualize quando explicitamente solicitado.
  </rule>
  
  <rule id="english-version" critical="true">
    A pasta `.english-version/` DEVE SEMPRE refletir os scripts da raiz.
    TODA criação/alteração de script DEVE ter versão em inglês.
  </rule>
  
  <rule id="cross-platform" critical="true">
    TODO script DEVE ter versão Linux (.sh) E Windows (.ps1).
    Se não existir solução nativa para uma plataforma, criar WRAPPER WSL.
    Consultar `core/project-structure.md` para exceções.
  </rule>
</rules>

## Projeto

Scripts utilitários de automação — idempotentes, bilíngues (PT na raiz, EN em `.english-version/`), multiplataforma.

<core-files>
  | Arquivo | Propósito | Quando Consultar |
  |---------|-----------|------------------|
  | `core/project-structure.md` | Estrutura atual do projeto | Quando precisar saber pastas/tipos existentes |
  | `core/skills-catalog.md` | Lista de skills disponíveis | Quando precisar saber qual skill carregar |
  | `core/workflow-engine.md` | Motor de execução | Referência de tags/sintaxe |
</core-files>

## Skills (Instruções sob Demanda)

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

<skill-deactivation>
  <trigger>Usuário diz: "desativar skill {nome}" ou "ignorar skill {nome}"</trigger>
  <action>Parar de aplicar regras dessa skill pelo resto da conversa</action>
  <action>Remover da lista de "skills em uso"</action>
  <output>⏹️ **Skill desativada**: `{nome}`</output>
  <note>Skills desativadas ainda estão no histórico mas suas regras são IGNORADAS</note>
</skill-deactivation>

<skill-loading critical="true">
  <mandate>Ao trabalhar com arquivos *.sh, VOCÊ DEVE ler e aplicar: {workspace}/.github/instructions/skills/bash.md</mandate>
  <mandate>Ao trabalhar com arquivos *.ps1, VOCÊ DEVE ler e aplicar: {workspace}/.github/instructions/skills/powershell.md</mandate>
  <mandate>Ao trabalhar com README.md, VOCÊ DEVE ler e aplicar: {workspace}/.github/instructions/skills/readme.md</mandate>
  <mandate>Após modificar scripts, VOCÊ DEVE ler e aplicar: {workspace}/.github/instructions/skills/sync.md</mandate>
  <mandate>Ao tomar decisão arquitetural importante, VOCÊ DEVE ler e aplicar: {workspace}/.github/instructions/skills/memory.md</mandate>
</skill-loading>

<skill-discovery critical="true">
  <mandate>Se a extensão do arquivo NÃO está listada acima:</mandate>
  <action>Ler: {workspace}/.github/instructions/core/skills-catalog.md</action>
  <action>Verificar se existe skill para a extensão</action>
  <check if="skill existe">
    <action>Carregar o skill indicado</action>
  </check>
  <check if="skill NÃO existe">
    <action>Ler: {workspace}/.github/instructions/skills/create-skill.md</action>
    <action>Criar skill para o novo tipo de arquivo</action>
  </check>
</skill-discovery>

<structure-update critical="true">
  <mandate>Após criar NOVA PASTA ou NOVO TIPO de script:</mandate>
  <action>Ler: {workspace}/.github/instructions/skills/update-structure.md</action>
  <action>Executar workflow de atualização de estrutura</action>
</structure-update>

## Task Complexity Workflow

<workflow id="task-analysis" trigger="on-user-request" priority="first">
  <step n="1" goal="Avaliar complexidade da tarefa">
    <criteria id="complex-task">
      Uma tarefa é COMPLEXA quando:
      - Envolve 4+ steps distintos
      - Usuário pede múltiplas coisas (lista numerada, vírgulas)
      - Envolve criar/modificar múltiplos arquivos
      - Requer sincronização cross-platform + english-version
      - Envolve criar nova pasta ou novo tipo de script
    </criteria>
    
    <check if="tarefa é COMPLEXA conforme critérios acima">
      <action>Criar TODO list com manage_todo_list</action>
      <action>Listar TODOS os steps identificados</action>
      <action>Marcar primeiro step como in-progress</action>
      <output>📋 Lista de tarefas criada</output>
    </check>
    
    <check if="tarefa é SIMPLES">
      <action>NÃO criar TODO list (evitar overhead)</action>
      <action>Executar diretamente</action>
    </check>
  </step>
</workflow>

<workflow id="task-completion" trigger="after-each-step">
  <step n="1" goal="Atualizar progresso">
    <check if="TODO list existe">
      <action>Marcar step atual como completed</action>
      <action>Marcar próximo step como in-progress (se houver)</action>
    </check>
  </step>
  
  <step n="2" goal="Revisar e ajustar" trigger="após-completar-step">
    <check if="novo step descoberto durante execução">
      <action>Adicionar novo step à lista</action>
      <action>Reordenar se necessário</action>
    </check>
    
    <check if="step atual revelou sub-tarefas">
      <action>Dividir em steps menores</action>
      <action>Atualizar lista</action>
    </check>
    
    <check if="step não é mais necessário">
      <action>Remover da lista</action>
    </check>
  </step>
  
  <step n="3" goal="Finalizar">
    <check if="todos os steps completed">
      <action>Verificar se TODO list está 100% concluída</action>
      <output>✅ Todas as tarefas concluídas</output>
    </check>
  </step>
</workflow>

## File Detection Workflow

<workflow id="file-detection" trigger="on-file-context">
  <step n="1" goal="Detectar tipo e carregar skill apropriada">
    <check if="contexto envolve arquivo *.sh OU pedido para criar script bash">
      <action>Ler COMPLETAMENTE: {workspace}/.github/instructions/skills/bash.md</action>
      <action>Aplicar todos os padrões e templates do skill</action>
    </check>
    
    <check if="contexto envolve arquivo *.ps1 OU pedido para criar script PowerShell">
      <action>Ler COMPLETAMENTE: {workspace}/.github/instructions/skills/powershell.md</action>
      <action>Aplicar todos os padrões e templates do skill</action>
    </check>
    
    <check if="contexto envolve README.md">
      <action>Ler COMPLETAMENTE: {workspace}/.github/instructions/skills/readme.md</action>
      <action>Aplicar estrutura obrigatória</action>
    </check>
    
    <check if="extensão NÃO reconhecida acima">
      <action>Consultar: {workspace}/.github/instructions/core/skills-catalog.md</action>
      <action>Seguir mapeamento extensão→skill</action>
    </check>
  </step>

  <step n="2" goal="Pós-modificação">
    <check if="script foi criado ou modificado">
      <action>Ler: {workspace}/.github/instructions/skills/sync.md</action>
      <action>Executar workflow de sincronização</action>
    </check>
    
    <check if="nova pasta foi criada OU novo tipo de arquivo">
      <action>Ler: {workspace}/.github/instructions/skills/update-structure.md</action>
      <action>Atualizar estrutura do projeto</action>
    </check>
  </step>
</workflow>

## Nomenclatura

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Arquivos | `verbo-substantivo.{ext}` | `install-docker.ps1` |
| Funções PS | `Verb-Noun` | `Test-Administrator` |
| Funções Bash | `snake_case` | `check_privileges` |
| Variáveis PS | `$PascalCase` | `$UserProfile` |
| Variáveis Bash | `snake_case` / `UPPER_CASE` | `user_home` / `RED` |

## Emojis & Cores

| Emoji | Uso | Cor PS | Cor Bash |
|-------|-----|--------|----------|
| 🔍 | Verificando | Cyan | `\033[0;36m` |
| 📦 | Instalando | Yellow | `\033[1;33m` |
| ✅ | Sucesso | Green | `\033[0;32m` |
| ❌ | Erro | Red | `\033[0;31m` |
| ⚠️ | Aviso | Yellow | `\033[1;33m` |
| 🔄 | Atualizando | Cyan | `\033[0;36m` |
| 🚀 | Executando | White | `\033[1;37m` |

## Segurança

<forbidden>
  - Senhas, tokens, API keys
  - IDs de tenant/subscription/recursos
  - Paths absolutos: `C:\Users\...`, `D:\Repos\...`, `/home/...`
  - URLs hardcoded de repos específicos
</forbidden>

<safe-paths>
  <powershell>$env:USERPROFILE, $env:APPDATA, $env:TEMP, $PSScriptRoot</powershell>
  <bash>$HOME, $XDG_CONFIG_HOME, /tmp, ${BASH_SOURCE[0]}</bash>
</safe-paths>

## Validation Workflow

<workflow id="pre-completion-validation" trigger="before-task-complete">
  <step n="1" goal="Validar script">
    <validate condition="script é idempotente">
      <halt if="false" reason="Script deve verificar estado antes de alterar"/>
    </validate>
    
    <validate condition="verifica pré-requisitos">
      <halt if="false" reason="Script deve verificar dependências"/>
    </validate>
    
    <validate condition="usa emojis e cores consistentes">
      <halt if="false" reason="Seguir padrão de emojis do projeto"/>
    </validate>
    
    <validate condition="tem tratamento de erros">
      <halt if="false" reason="Adicionar try/catch ou set -e"/>
    </validate>
    
    <validate condition="sem dados sensíveis">
      <halt if="false" reason="Remover senhas, tokens, paths absolutos"/>
    </validate>
  </step>

  <step n="2" goal="Validar sincronização">
    <validate condition="versão EN existe ou será criada">
      <halt if="false" reason="Criar versão em .english-version/"/>
    </validate>
    
    <validate condition="README atualizado (se mudança funcional)">
      <halt if="false" reason="Atualizar README com mudanças"/>
    </validate>
  </step>
</workflow>

## Checklist Obrigatório

<checklist context="qualquer-script" execute="always">
  - [ ] Idempotente
  - [ ] Verifica pré-requisitos
  - [ ] Cores e emojis consistentes
  - [ ] Feedback de progresso
  - [ ] Tratamento de erros
  - [ ] Versão PT e EN
  - [ ] README da pasta existe e atualizado
  - [ ] Sem dados sensíveis
  - [ ] Sem paths absolutos
</checklist>

