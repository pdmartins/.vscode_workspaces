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

<lesson date="2026-01-30" category="arquitetura">
  <context>Instruções do Copilot estavam extensas e difíceis de manter</context>
  <decision>Migrar para formato Markdown + XML com diretivas separadas por tipo de arquivo</decision>
  <outcome>
    - Instruções mais compactas e legíveis
    - Diretivas específicas para .ps1, .sh, README.md
    - Melhor manutenibilidade
  </outcome>
</lesson>

<lesson date="2026-01-30" category="organização">
  <context>Necessidade de separar instruções condicionais de referências diretas</context>
  <decision>
    - `default.instructions.md`: regras gerais com condicionais `<when>`
    - `directives/*.md`: templates e padrões sem condicionais
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
