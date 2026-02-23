# English Version Rules

<rules id="english-version" critical="true">

## Regra Fundamental

<rule>
  A pasta `.english-version/` DEVE SEMPRE refletir os scripts da raiz.
  TODA criação/alteração de script DEVE ter versão em inglês.
</rule>

## Estrutura

```
scripts/                      # Versão PT-BR (raiz)
├── docker/
│   ├── install-docker.sh
│   ├── install-docker.ps1
│   └── README.md
└── .english-version/         # Versão EN (espelho)
    └── docker/
        ├── install-docker.sh
        ├── install-docker.ps1
        └── README.md
```

## O Que Traduzir

| Elemento | Traduzir? | Exemplo PT | Exemplo EN |
|----------|-----------|------------|------------|
| Comentários | ✅ Sim | `# Verifica admin` | `# Check admin` |
| Mensagens output | ✅ Sim | `"Instalando..."` | `"Installing..."` |
| Nomes de variáveis | ❌ Não | `$UserProfile` | `$UserProfile` |
| Nomes de funções | ❌ Não | `Test-Admin` | `Test-Admin` |
| README conteúdo | ✅ Sim | Todo o texto | Todo o texto |
| Nomes de arquivos | ❌ Não | `install-docker.sh` | `install-docker.sh` |

## Workflow

<workflow id="english-sync">
  <step n="1" goal="Criar versão EN">
    <action>Copiar script para .english-version/{pasta}/</action>
    <action>Traduzir TODOS os comentários</action>
    <action>Traduzir TODAS as mensagens de output</action>
    <action>Manter nomes de variáveis/funções iguais</action>
  </step>

  <step n="2" goal="Criar README EN">
    <check if="README.md foi criado ou modificado">
      <action>Criar/atualizar .english-version/{pasta}/README.md</action>
      <action>Traduzir todo o conteúdo</action>
    </check>
  </step>

  <step n="3" goal="Validar sincronização">
    <validate condition="estrutura EN espelha raiz">
      <halt if="false" reason="Estrutura .english-version/ não está sincronizada"/>
    </validate>
  </step>
</workflow>

## Checklist

<checklist>
  - [ ] Script EN existe em .english-version/
  - [ ] Comentários traduzidos
  - [ ] Mensagens de output traduzidas
  - [ ] README EN existe e traduzido
  - [ ] Estrutura de pastas espelhada
</checklist>

</rules>
