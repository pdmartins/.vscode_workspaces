# TODO Workflow

<system id="todo-workflow" version="1.0">
  <objective>Gestão de tarefas complexas com visibilidade para o usuário</objective>
  <tool>manage_todo_list</tool>
</system>

## Task Analysis Workflow

<workflow id="task-analysis" trigger="on-user-request" priority="first">
  <step n="1" goal="Avaliar complexidade da tarefa">
    <criteria id="complex-task">
      Uma tarefa é COMPLEXA quando:
      - Envolve 4+ steps distintos
      - Usuário pede múltiplas coisas (lista numerada, vírgulas)
      - Envolve criar/modificar múltiplos arquivos
      - Requer múltiplas sincronizações ou validações
      - Envolve criar nova estrutura ou tipo de arquivo
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

## Task Completion Workflow

<workflow id="task-completion" trigger="after-each-step">
  <step n="1" goal="Atualizar progresso">
    <check if="TODO list existe">
      <action>Marcar step atual como completed</action>
      <action>Marcar próximo step como in-progress (se houver)</action>
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

## TODO States

<states>
  | Estado | Significado |
  |--------|-------------|
  | not-started | Ainda não iniciado |
  | in-progress | Em execução (máximo 1 por vez) |
  | completed | Concluído com sucesso |
</states>
