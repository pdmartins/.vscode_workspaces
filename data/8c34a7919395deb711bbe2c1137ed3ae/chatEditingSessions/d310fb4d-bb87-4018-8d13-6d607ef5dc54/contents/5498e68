# Lessons Learned

Registro de aprendizados e decisões importantes do projeto.

---

## Estrutura

<lesson date="YYYY-MM-DD" category="categoria">
  <context>Contexto do problema</context>
  <decision>Decisão tomada</decision>
  <outcome>Resultado/impacto</outcome>
</lesson>

---

## Registro

<lesson date="2026-01-31" category="arquitetura">
  <context>
    Projeto precisa suportar novos tipos de scripts (SQL, Python, AWS, etc) sem carregar
    todas as instruções de uma vez. Estrutura e lista de skills mudam com frequência.
  </context>
  <decision>
    Separar informações dinâmicas em arquivos dedicados:
    - core/project-structure.md: estrutura atual do projeto (pastas, tipos)
    - core/skills-catalog.md: catálogo de skills com mapeamento extensão→skill
    - skills/update-structure.md: skill para atualizar estrutura
    - skills/create-skill.md: skill para criar novos skills
    
    default.instructions.md mantém apenas:
    - Regras fundamentais (idioma, segurança)
    - Mandatos de carregamento de skills
    - Referências aos arquivos core
  </decision>
  <outcome>
    - Estrutura extensível para novos tipos de script
    - Carregamento mínimo (só o necessário)
    - Auto-documentado (agente sabe como atualizar)
  </outcome>
</lesson>

<lesson date="2026-01-31" category="arquitetura">
  <context>
    Arquivos .instructions.md com applyTo específico só são carregados quando o arquivo
    correspondente está no contexto do chat (adicionado com #file ou aberto no editor).
    Isso significa que pedir para "criar um script bash" não carregaria automaticamente
    as instruções de bash.instructions.md.
  </context>
  <decision>
    Adotar modelo de "Skills" sob demanda:
    - Skills ficam em pasta separada: skills/*.md
    - Não usam applyTo (são carregados explicitamente)
    - default.instructions.md contém mandatos explícitos para carregar skills
    - Usa tags <mandate> para instruir o modelo a ler arquivos quando contexto detectado
  </decision>
  <outcome>
    - Controle explícito sobre quando skills são carregados
    - Menor overhead (não carrega tudo sempre)
    - Modelo recebe instrução clara para buscar e aplicar skills
  </outcome>
</lesson>

<lesson date="2026-01-31" category="arquitetura">
  <context>
    Instruções condicionais no default.instructions.md (tags <when>) não eram seguidas 
    pelo Copilot porque LLMs interpretam XML como contexto, não como comandos executáveis.
  </context>
  <decision>
    Migrar para arquitetura de Workflow Engine inspirada no BMAD Method:
    - Criar core/workflow-engine.md como motor central
    - Estruturar instruções em workflows com steps numerados
    - Usar tags <check>, <action>, <validate>, <halt> para controle de fluxo
    - Skills carregados sob demanda via mandatos explícitos
  </decision>
  <outcome>
    - Instruções organizadas em workflows determinísticos
    - Skills carregados quando contexto apropriado detectado
    - Estrutura escalável e fácil de manter
  </outcome>
</lesson>

<lesson date="2026-01-30" category="organização">
  <context>Necessidade de separar instruções condicionais de referências diretas</context>
  <decision>
    - `default.instructions.md`: regras gerais com engine loader
    - `skills/*.md`: instruções específicas por tipo de arquivo
    - `core/*.md`: arquivos de referência e motor
  </decision>
  <outcome>Estrutura clara e fácil de estender</outcome>
</lesson>

---

## Categorias

| Categoria | Descrição |
|-----------|-----------|
| arquitetura | Decisões estruturais |
| padrões | Convenções de código |
| segurança | Práticas de segurança |
| tooling | Ferramentas e automação |
| bugs | Correções importantes |
