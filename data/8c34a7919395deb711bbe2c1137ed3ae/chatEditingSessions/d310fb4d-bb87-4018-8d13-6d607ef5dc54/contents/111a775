# Skill: Memory

<skill id="memory" context="persistência de contexto entre sessões do Copilot">

## Propósito

O `.memory/` é a **memória persistente do Copilot** para este workspace.
Diferente de README e docs (para humanos), estes arquivos são para o Copilot
"lembrar" de decisões passadas, evitando repetir erros e mantendo consistência.

## Quando Usar Este Skill

<triggers>
  - Decisão arquitetural importante foi tomada
  - Erro foi cometido e corrigido (lição aprendida)
  - Contexto do projeto mudou significativamente
  - Novo padrão foi estabelecido
  - Usuário pede para "lembrar" algo
</triggers>

## Estrutura do .memory

<folder-structure>
```
.github/.memory/
├── lessons-learned.md    # Lições e decisões importantes
└── project-context.md    # Contexto atual do projeto
```
</folder-structure>

## Workflow: Registrar Lição

<workflow id="register-lesson">
  <step n="1" goal="Identificar se é uma lição válida">
    <check if="decisão arquitetural importante">
      <action>Registrar em lessons-learned.md</action>
    </check>
    
    <check if="erro corrigido com aprendizado">
      <action>Registrar em lessons-learned.md</action>
    </check>
    
    <check if="padrão novo estabelecido">
      <action>Registrar em lessons-learned.md</action>
    </check>
    
    <check if="mudança trivial ou temporária">
      <action>NÃO registrar - evitar poluição</action>
    </check>
  </step>

  <step n="2" goal="Formatar a lição">
    <template>
```xml
<lesson date="YYYY-MM-DD" category="categoria">
  <context>Contexto do problema ou situação</context>
  <decision>Decisão tomada e por quê</decision>
  <outcome>Resultado e impacto</outcome>
</lesson>
```
    </template>
    
    <categories>
      | Categoria | Quando Usar |
      |-----------|-------------|
      | arquitetura | Estrutura do projeto, organização |
      | padrões | Convenções de código, nomenclatura |
      | tooling | Ferramentas, dependências, configs |
      | workflow | Processos, automações |
      | debug | Problemas resolvidos, armadilhas |
    </categories>
  </step>

  <step n="3" goal="Adicionar ao arquivo">
    <action>Ler: {workspace}/.github/.memory/lessons-learned.md</action>
    <action>Adicionar nova lesson após "## Registro"</action>
    <action>Manter ordem cronológica (mais recente primeiro)</action>
  </step>
</workflow>

## Workflow: Consultar Memória

<workflow id="consult-memory" trigger="início de tarefa complexa">
  <step n="1" goal="Verificar lições relevantes">
    <action>Ler: {workspace}/.github/.memory/lessons-learned.md</action>
    <action>Identificar lições relacionadas à tarefa atual</action>
    <action>Aplicar aprendizados para evitar erros passados</action>
  </step>

  <step n="2" goal="Verificar contexto do projeto">
    <check if="arquivo project-context.md existe">
      <action>Ler: {workspace}/.github/.memory/project-context.md</action>
      <action>Considerar contexto nas decisões</action>
    </check>
  </step>
</workflow>

## Workflow: Atualizar Contexto

<workflow id="update-context">
  <step n="1" goal="Identificar mudança de contexto">
    <triggers>
      - Novo objetivo principal do projeto
      - Mudança de stack tecnológico
      - Novas restrições ou requisitos
      - Integração com novos sistemas
    </triggers>
  </step>

  <step n="2" goal="Atualizar project-context.md">
    <action>Ler ou criar: {workspace}/.github/.memory/project-context.md</action>
    <action>Atualizar seções relevantes</action>
    
    <template>
```markdown
# Project Context

## Objetivo
{descrição do objetivo principal do projeto}

## Stack
{tecnologias principais}

## Restrições
{limitações, requisitos não-funcionais}

## Integrações
{sistemas externos, APIs}

## Decisões Ativas
{decisões que ainda impactam desenvolvimento}

## Última Atualização
{data e motivo}
```
    </template>
  </step>
</workflow>

## Quando NÃO Registrar

<anti-patterns>
  - Mudanças triviais de código
  - Decisões temporárias ou experimentais
  - Informações já documentadas em README
  - Detalhes de implementação específicos
  - Logs de atividade (não é changelog)
</anti-patterns>

## Integração com Outros Skills

<integration>
  <on-trigger skill="create-skill">
    Se novo skill criado representa decisão arquitetural →
    Registrar em lessons-learned.md
  </on-trigger>
  
  <on-trigger skill="update-structure">
    Se estrutura mudou significativamente →
    Verificar se project-context.md precisa atualização
  </on-trigger>
</integration>

</skill>
