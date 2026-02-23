# Prompt: Setup Workflow Engine para Copilot Instructions

> Use este prompt para instruir um agente VS Code a criar/revisar a estrutura de Workflow Engine em qualquer projeto.

---

## Prompt para o Agente

```
Preciso que você crie/revise a estrutura de instruções do Copilot neste workspace utilizando uma arquitetura de Workflow Engine inspirada no BMAD Method.

## Contexto

LLMs interpretam XML como contexto, não como comandos executáveis. Instruções condicionais simples (como <when>) não funcionam bem. A solução é usar workflows estruturados com mandatos explícitos.

## Arquitetura a Implementar

### Estrutura de Pastas

```
.github/
├── instructions/
│   ├── default.instructions.md    # Sempre carregado (applyTo: '**')
│   ├── core/                      # Arquivos de referência
│   │   ├── workflow-engine.md     # Documentação das tags/sintaxe
│   │   ├── project-structure.md   # Estrutura atual do projeto (dinâmico)
│   │   └── skills-catalog.md      # Catálogo de skills (dinâmico)
│   └── skills/                    # Skills sob demanda
│       ├── {linguagem}.md         # Ex: bash.md, powershell.md, python.md
│       ├── readme.md              # Para arquivos README.md
│       ├── sync.md                # Sincronização pós-modificação
│       ├── memory.md              # Persistência de contexto
│       ├── update-structure.md    # Atualizar estrutura do projeto
│       └── create-skill.md        # Criar novos skills
└── .memory/                       # Memória persistente do Copilot
    ├── lessons-learned.md         # Lições e decisões importantes
    └── project-context.md         # Contexto atual do projeto
```

### Princípios Fundamentais

1. **Skills sob demanda**: NÃO carregar todas instruções de uma vez. Skills são carregados via mandatos explícitos quando contexto apropriado é detectado.

2. **Mandatos explícitos**: Usar tag <mandate> para instruções obrigatórias que o agente DEVE seguir.

3. **Workflows estruturados**: Usar <workflow>, <step>, <check>, <action>, <validate> para controle de fluxo.

4. **Anúncio de skills**: Quando skill for ativada, anunciar: "🔧 **Skill ativada**: `{nome}`"

5. **TODO list para tarefas complexas**: Usar manage_todo_list quando tarefa tiver 4+ steps, múltiplos arquivos, ou múltiplas solicitações.

### Conteúdo do default.instructions.md

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

3. **Skill Announcement**
```xml
<skill-announcement critical="true">
  <mandate>Ao carregar uma skill, VOCÊ DEVE anunciar no início da resposta:</mandate>
  <format>🔧 **Skill ativada**: `{nome-da-skill}`</format>
</skill-announcement>
```

4. **Skill Loading** - Mandatos para carregar skills por contexto:
```xml
<skill-loading critical="true">
  <mandate>Ao trabalhar com arquivos *.{ext}, VOCÊ DEVE ler e aplicar: {workspace}/.github/instructions/skills/{skill}.md</mandate>
  <!-- Repetir para cada tipo de arquivo do projeto -->
</skill-loading>
```

5. **Skill Discovery** - Para extensões não mapeadas:
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

6. **Task Complexity Workflow** - Avaliar se usa TODO:
```xml
<workflow id="task-analysis" trigger="on-user-request" priority="first">
  <step n="1" goal="Avaliar complexidade da tarefa">
    <criteria id="complex-task">
      Uma tarefa é COMPLEXA quando:
      - Envolve 4+ steps distintos
      - Usuário pede múltiplas coisas (lista numerada, vírgulas)
      - Envolve criar/modificar múltiplos arquivos
    </criteria>
    
    <check if="tarefa é COMPLEXA">
      <action>Criar TODO list com manage_todo_list</action>
      <action>Marcar primeiro step como in-progress</action>
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
    </check>
  </step>
</workflow>
```

7. **File Detection Workflow** - Detectar tipo e carregar skill
8. **Validation Workflow** - Validações pré-conclusão
9. **Checklist Obrigatório** - Adaptar ao projeto

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

### Skills Obrigatórios

1. **memory.md** - Persistência de contexto entre sessões
   - Registrar lições em lessons-learned.md
   - Atualizar project-context.md quando contexto mudar
   - Consultar memória em tarefas complexas

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

### .memory/lessons-learned.md

Estrutura para registrar lições:
```xml
<lesson date="YYYY-MM-DD" category="categoria">
  <context>Contexto do problema</context>
  <decision>Decisão tomada</decision>
  <outcome>Resultado/impacto</outcome>
</lesson>
```

Categorias: arquitetura, padrões, tooling, workflow, debug

### .memory/project-context.md

Deve conter:
- Objetivo do projeto
- Stack tecnológico
- Restrições
- Integrações
- Decisões ativas

## Instruções de Execução

1. Analise a estrutura atual do projeto
2. Identifique as linguagens/tipos de arquivo usados
3. Crie a estrutura de pastas .github/instructions/ e .github/.memory/
4. Crie default.instructions.md adaptado ao projeto
5. Crie core/workflow-engine.md com referência das tags
6. Crie core/project-structure.md com estrutura atual
7. Crie core/skills-catalog.md com mapeamento extensão→skill
8. Crie skills para cada tipo de arquivo do projeto
9. Crie skills obrigatórios (memory, sync, readme, update-structure, create-skill)
10. Crie .memory/lessons-learned.md com estrutura inicial
11. Crie .memory/project-context.md com contexto do projeto

Pergunte-me sobre regras específicas do projeto antes de começar (idioma, nomenclatura, etc).
```

---

## Notas de Uso

- Copie o conteúdo entre os blocos ``` e cole no chat do outro workspace
- O agente deve fazer perguntas sobre especificidades do projeto
- Revise os skills criados para garantir que refletem as práticas do projeto
- Teste com uma tarefa simples e uma complexa para validar o funcionamento
