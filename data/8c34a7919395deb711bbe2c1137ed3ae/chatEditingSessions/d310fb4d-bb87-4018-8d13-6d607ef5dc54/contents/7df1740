# Prompt: Setup Workflow Engine para Copilot Instructions (BMAD Integration)

> Use este prompt para instruir um agente VS Code a criar/revisar a estrutura de Workflow Engine em um projeto que já possui estrutura BMAD.

---

## Prompt para o Agente

```
Preciso que você crie/revise a estrutura de instruções do Copilot neste workspace, integrando com a estrutura BMAD existente.

## Contexto

Este projeto já possui uma estrutura BMAD em `.github/.bmad/` com:
- agents/ - Agentes especializados
- workflows/ - Workflows por fase (analysis, plan, solutioning, implementation)
- _memory/ - Memória persistente
- _config/ - Configurações

LLMs interpretam XML como contexto, não como comandos executáveis. Instruções condicionais simples (como <when>) não funcionam bem. A solução é usar workflows estruturados com mandatos explícitos.

## Arquitetura a Implementar

### Estrutura de Pastas (Integrada com BMAD)

```
.github/
├── instructions/
│   ├── initial.instructions.md    # Sempre carregado (applyTo: '**')
│   ├── core/                      # Arquivos de referência
│   │   ├── workflow-engine.md     # Documentação das tags/sintaxe
│   │   ├── project-structure.md   # Estrutura atual do projeto (dinâmico)
│   │   └── skills-catalog.md      # Catálogo de skills (dinâmico)
│   └── skills/                    # Skills sob demanda
│       ├── {linguagem}.md         # Ex: typescript.md, python.md
│       ├── readme.md              # Para arquivos README.md
│       ├── sync.md                # Sincronização pós-modificação
│       ├── memory.md              # Integração com .bmad/_memory
│       ├── update-structure.md    # Atualizar estrutura do projeto
│       └── create-skill.md        # Criar novos skills
└── .bmad/                         # Estrutura BMAD existente
    ├── agents/                    # Agentes especializados ← INTEGRAR
    ├── workflows/                 # Workflows BMAD
    ├── _memory/                   # Memória persistente ← USAR
    └── _config/                   # Configurações
```

### Princípios Fundamentais

1. **Skills sob demanda**: NÃO carregar todas instruções de uma vez. Skills são carregados via mandatos explícitos quando contexto apropriado é detectado.

2. **Agentes BMAD sob demanda**: Agentes da pasta `.bmad/agents/` são carregados quando contexto apropriado detectado OU quando usuário solicita explicitamente.

3. **Mandatos explícitos**: Usar tag <mandate> para instruções obrigatórias que o agente DEVE seguir.

4. **Workflows estruturados**: Usar <workflow>, <step>, <check>, <action>, <validate> para controle de fluxo.

5. **Anúncio de skills/agentes**: Quando skill ou agente for ativado, anunciar no início da resposta.

6. **TODO list para tarefas complexas**: Usar manage_todo_list quando tarefa tiver 4+ steps, múltiplos arquivos, ou múltiplas solicitações.

7. **Memória unificada**: Usar `.bmad/_memory/` como memória persistente (não duplicar).

### Conteúdo do initial.instructions.md

Deve conter:

1. **Engine Loader** (crítico)
```xml
<engine-loader critical="true">
  <mandate>Este arquivo governa TODAS as operações no workspace</mandate>
  <mandate>Instruções são OBRIGATÓRIAS, não sugestões</mandate>
  <mandate>Execute workflows em ORDEM EXATA</mandate>
  <mandate>NÃO carregue todos os arquivos - carregue APENAS quando necessário</mandate>
</engine-loader>
```

2. **Regras Fundamentais** - Adaptar ao projeto:
   - Idioma (chat vs código)
   - Regras de nomenclatura
   - Regras de segurança (sem senhas, tokens, paths absolutos)
   - Regras específicas do projeto

3. **Skill/Agent Announcement**
```xml
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

<agent-announcement critical="true">
  <mandate>Quando ativar um agente BMAD, anunciar:</mandate>
  <format>🤖 **Agente ativado**: `{nome-do-agente}`</format>
</agent-announcement>

<skill-deactivation>
  <trigger>Usuário diz: "desativar skill {nome}" ou "ignorar skill {nome}"</trigger>
  <action>Parar de aplicar regras dessa skill pelo resto da conversa</action>
  <action>Remover da lista de "skills em uso"</action>
  <output>⏹️ **Skill desativada**: `{nome}`</output>
  <note>Skills desativadas ainda estão no histórico mas suas regras são IGNORADAS</note>
</skill-deactivation>
```

4. **Agent Loading** - Carregar agentes BMAD por contexto:
```xml
<agent-loading critical="true">
  <mandate>PRIMEIRO, listar todos os agentes disponíveis em: {workspace}/.github/.bmad/agents/</mandate>
  <mandate>Para cada agente, identificar seu propósito pelo nome do arquivo</mandate>
  
  <workflow id="agent-detection">
    <step n="1" goal="Detectar necessidade de agente">
      <check if="usuário menciona explicitamente um agente">
        <action>Carregar agente: {workspace}/.github/.bmad/agents/{agente}.md</action>
        <output>🤖 **Agente ativado**: `{agente}`</output>
      </check>
      
      <check if="contexto sugere necessidade de agente especializado">
        <action>Sugerir agentes relevantes ao usuário</action>
        <output>💡 Agentes disponíveis para este contexto: {lista}</output>
      </check>
    </step>
  </workflow>
</agent-loading>
```

5. **Skill Loading** - Mandatos para carregar skills por extensão:
```xml
<skill-loading critical="true">
  <mandate>Ao trabalhar com arquivos *.{ext}, VOCÊ DEVE ler e aplicar: {workspace}/.github/instructions/skills/{skill}.md</mandate>
  <!-- Repetir para cada tipo de arquivo do projeto -->
</skill-loading>
```

6. **Skill Discovery** - Para extensões não mapeadas:
```xml
<skill-discovery critical="true">
  <mandate>Se a extensão do arquivo NÃO está listada acima:</mandate>
  <action>Ler: {workspace}/.github/instructions/core/skills-catalog.md</action>
  <action>Verificar se existe skill para a extensão</action>
  <check if="skill NÃO existe">
    <action>Ler: {workspace}/.github/instructions/skills/create-skill.md</action>
    <action>Criar skill para o novo tipo de arquivo</action>
  </check>
</skill-discovery>
```

7. **Task Complexity Workflow** - Avaliar se usa TODO:
```xml
<workflow id="task-analysis" trigger="on-user-request" priority="first">
  <step n="1" goal="Avaliar complexidade da tarefa">
    <criteria id="complex-task">
      Uma tarefa é COMPLEXA quando:
      - Envolve 4+ steps distintos
      - Usuário pede múltiplas coisas (lista numerada, vírgulas)
      - Envolve criar/modificar múltiplos arquivos
      - Envolve executar workflow BMAD completo
    </criteria>
    
    <check if="tarefa é COMPLEXA">
      <action>Criar TODO list com manage_todo_list</action>
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
      <action>Marcar próximo step como in-progress</action>
    </check>
  </step>
  
  <step n="2" goal="Revisar e ajustar">
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
```

8. **File Detection Workflow** - Detectar tipo e carregar skill
9. **Validation Workflow** - Validações pré-conclusão
10. **Checklist Obrigatório** - Adaptar ao projeto

### Estrutura de um Skill

Cada skill deve seguir esta estrutura:
```xml
<skill id="{nome}" context="{quando usar}">
  <triggers>
    - Quando criar/editar arquivos *.{ext}
    - {outros gatilhos}
  </triggers>
  
  <workflow id="{nome}-workflow">
    <step n="1" goal="{objetivo}">
      <check if="{condição}">
        <action>{ação}</action>
      </check>
    </step>
  </workflow>
  
  <!-- Template, padrões, convenções -->
</skill>
```

### Integração com Agentes BMAD

Os agentes na pasta `.bmad/agents/` devem ser mapeados no `initial.instructions.md`:

```xml
<bmad-agents>
  <mandate>Ler lista de agentes em: {workspace}/.github/.bmad/agents/</mandate>
  
  <agent-mapping>
    <!-- Preencher após listar agentes disponíveis -->
    | Agente | Arquivo | Quando Ativar |
    |--------|---------|---------------|
    | {nome} | agents/{arquivo}.md | {contexto de ativação} |
  </agent-mapping>
  
  <activation-rules>
    <rule>Usuário solicita explicitamente o agente</rule>
    <rule>Contexto da tarefa corresponde à especialidade do agente</rule>
    <rule>Workflow BMAD requer o agente</rule>
  </activation-rules>
</bmad-agents>
```

### Skills Obrigatórios

1. **memory.md** - Integração com `.bmad/_memory/`
   - Registrar lições em _memory/lessons-learned.md (criar se não existir)
   - Atualizar project-context.md quando contexto mudar
   - Consultar memória em tarefas complexas
   - **NÃO duplicar** - usar estrutura _memory existente

2. **sync.md** - Sincronização pós-modificação (adaptar ao projeto)
   - Verificar contrapartes necessárias
   - Atualizar README da pasta
   - Regras de versionamento

3. **readme.md** - Estrutura de README por pasta/módulo
   - Template obrigatório
   - Seções requeridas

4. **update-structure.md** - Manter project-structure.md atualizado
5. **create-skill.md** - Criar novos skills quando necessário

### Tags Suportadas

| Tag | Propósito |
|-----|-----------|
| `<mandate>` | Instrução OBRIGATÓRIA |
| `<workflow>` | Agrupa steps sequenciais |
| `<step n="N" goal="">` | Passo numerado com objetivo |
| `<check if="">` | Condicional |
| `<action>` | Ação a executar |
| `<validate condition="">` | Validação com halt |
| `<halt if="" reason="">` | Interrompe se condição verdadeira |
| `<output>` | Mensagem para usuário |
| `<template>` | Template de código/estrutura |

### Integração com .bmad/_memory/

Usar a estrutura existente. Se não existir lessons-learned.md, criar:
```xml
<lesson date="YYYY-MM-DD" category="categoria">
  <context>Contexto do problema</context>
  <decision>Decisão tomada</decision>
  <outcome>Resultado/impacto</outcome>
</lesson>
```

Categorias: arquitetura, padrões, tooling, workflow, debug, bmad

### project-context.md (em _memory/)

Deve conter:
- Objetivo do projeto
- Stack tecnológico
- Restrições
- Integrações
- Decisões ativas
- Agentes BMAD disponíveis

## Instruções de Execução

1. **Analisar estrutura existente**:
   - Listar arquivos em `.github/.bmad/agents/` e identificar cada agente
   - Verificar estrutura de `.github/.bmad/_memory/`
   - Identificar linguagens/tipos de arquivo usados no projeto

2. **Criar estrutura de instructions**:
   - Criar `.github/instructions/` (se não existir)
   - Criar `initial.instructions.md` com integração BMAD
   - Criar `core/workflow-engine.md` com referência das tags
   - Criar `core/project-structure.md` com estrutura atual (incluindo BMAD)
   - Criar `core/skills-catalog.md` com mapeamento extensão→skill

3. **Criar skills**:
   - Criar skills para cada tipo de arquivo do projeto
   - Criar skills obrigatórios (memory, sync, readme, update-structure, create-skill)
   - memory.md deve apontar para `.bmad/_memory/` (não duplicar)

4. **Integrar agentes BMAD**:
   - Mapear cada agente com seu contexto de ativação
   - Adicionar regras de ativação no initial.instructions.md
   - Documentar agentes no project-structure.md

5. **Configurar memória**:
   - Criar/atualizar `.bmad/_memory/lessons-learned.md`
   - Criar/atualizar `.bmad/_memory/project-context.md`

6. **Perguntar ao usuário**:
   - Regras de idioma (chat vs código)
   - Regras de nomenclatura do projeto
   - Regras específicas de sincronização
   - Quais agentes devem ser ativados automaticamente vs sob demanda

## Primeira Ação

Antes de criar qualquer arquivo:
1. Liste todos os agentes em `.github/.bmad/agents/`
2. Pergunte ao usuário sobre regras específicas do projeto
3. Confirme o mapeamento de agentes com o usuário
```

---

## Notas de Uso

- Copie o conteúdo entre os blocos ``` e cole no chat do outro workspace
- O agente vai listar os agentes BMAD existentes e perguntar sobre configurações
- Revise o mapeamento de agentes antes de confirmar
- Teste ativando um agente explicitamente para validar o funcionamento
- Teste uma tarefa complexa para validar o TODO list
