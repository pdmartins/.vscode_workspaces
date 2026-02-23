# Skill: Create Skill

<skill id="create-skill" context="quando precisar criar skill para novo tipo de script">

## Quando Usar Este Skill

<triggers>
  - Novo tipo de script solicitado (ex: .sql, .py, .bat, .js)
  - Extensão sem skill mapeado no skills-catalog.md
  - Necessidade de padrões específicos para nova linguagem/plataforma
</triggers>

## Workflow

<workflow id="create-skill-workflow">
  <step n="1" goal="Coletar informações do novo skill">
    <action>Identificar extensão do arquivo (ex: .sql, .py)</action>
    <action>Identificar linguagem/plataforma (ex: SQL, Python, AWS CLI)</action>
    <action>Identificar contexto de uso (ex: banco de dados, automação, cloud)</action>
    
    <ask>
      Forneça:
      1. Extensão do arquivo (ex: .sql)
      2. Nome do skill (ex: sql)
      3. Descrição breve
      4. Requisitos/dependências típicas
    </ask>
  </step>

  <step n="2" goal="Criar arquivo do skill">
    <action>Criar arquivo: {workspace}/.github/instructions/skills/{skill-name}.md</action>
    
    <template>
```markdown
# {Linguagem} Script Instructions

<skill id="{skill-name}" context="*.{ext} files">

## Quando Usar Este Skill

<triggers>
  - Criar/editar arquivos `*.{ext}`
  - {contextos específicos}
</triggers>

## Workflow

<workflow id="{skill-name}-script-workflow">
  <step n="1" goal="Validar estrutura do script">
    <check if="arquivo novo">
      <action>Aplicar template base</action>
    </check>
    
    <check if="arquivo existente">
      <action>Preservar estrutura existente</action>
    </check>
  </step>

  <step n="2" goal="Verificar elementos obrigatórios">
    {validações específicas da linguagem}
  </step>

  <step n="3" goal="Aplicar padrões">
    {padrões da linguagem}
  </step>
</workflow>

## Template Base

\`\`\`{ext}
{template da linguagem}
\`\`\`

## Padrões de Código

<patterns>
  {padrões específicos}
</patterns>

## Convenções

<conventions>
  <naming>
    {regras de nomenclatura}
  </naming>
  
  <structure>
    {regras de estrutura}
  </structure>
</conventions>

</skill>
```
    </template>
  </step>

  <step n="3" goal="Atualizar skills-catalog.md">
    <action>Ler: {workspace}/.github/instructions/core/skills-catalog.md</action>
    
    <action>Adicionar na seção "Scripts por Linguagem" ou categoria apropriada:
      | {skill-name} | `skills/{skill-name}.md` | Criar/editar arquivos `*.{ext}` |
    </action>
    
    <action>Adicionar em "Extensões → Skills":
      | .{ext} | {skill-name} |
    </action>
    
    <action>Remover de "Skills Pendentes" se estava listado</action>
    
    <action>Atualizar campo updated na metadata</action>
  </step>

  <step n="4" goal="Atualizar project-structure.md">
    <action>Ler: {workspace}/.github/instructions/core/project-structure.md</action>
    
    <action>Adicionar extensão na tabela "Tipos de Script Suportados":
      | .{ext} | {skill-name} | {descrição} |
    </action>
    
    <action>Atualizar árvore de estrutura se skill foi adicionado</action>
  </step>

  <step n="5" goal="Confirmar criação">
    <output>
      ✅ **Skill Criado**
      
      | Item | Status |
      |------|--------|
      | skills/{skill-name}.md | ✅ Criado |
      | core/skills-catalog.md | ✅ Atualizado |
      | core/project-structure.md | ✅ Atualizado |
      
      **Próximos passos:**
      - Testar criando um script .{ext}
      - Ajustar template conforme necessário
    </output>
  </step>
</workflow>

## Skills Comuns (templates de referência)

<reference-templates>
  | Tipo | Elementos Típicos |
  |------|-------------------|
  | SQL | Header com autor/data, transações, rollback |
  | Python | Shebang, docstrings, if __name__ == "__main__" |
  | Batch | @echo off, setlocal, exit codes |
  | JavaScript/Node | 'use strict', exports, async/await |
  | AWS CLI | Profile, region, error handling |
</reference-templates>

## Checklist

<checklist>
  - [ ] Arquivo skills/{skill-name}.md criado
  - [ ] Template base definido
  - [ ] Padrões de código documentados
  - [ ] skills-catalog.md atualizado
  - [ ] project-structure.md atualizado
  - [ ] Mapeamento extensão→skill adicionado
</checklist>

</skill>
