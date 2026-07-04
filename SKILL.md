---
name: harness-init
description: Cria a stack completa de engenharia confiável (spec + CLAUDE.md + hooks + regras modulares) em qualquer projeto. Use quando o usuário pedir para inicializar o harness, montar a estrutura da aula, subir o controle antes de codar, ou preparar um projeto para desenvolvimento assistido por agente. Materializa .spec.md, CLAUDE.md, .claude/settings.json, .claude/rules/*.md e .claude/hooks/*.sh na raiz do projeto atual.
---

# harness-init

Este skill materializa a stack de engenharia confiável em qualquer projeto. Ele **não implementa** o domínio — só sobe o harness (a camada de controle) antes de qualquer código.

## Quando usar

O usuário disse coisas como:
- "monta o harness aqui"
- "inicializa a estrutura da aula"
- "sobe o controle antes de codar"
- "prepara esse projeto pro Claude Code"
- "cria a stack de engenharia confiável"

## O que cria

Na pasta de trabalho atual (nunca criar pasta nova — usar o CWD):

```
./
├── .spec.md                          ← template de contrato, o usuário preenche
├── CLAUDE.md                         ← regras do projeto, referencia módulos
└── .claude/
    ├── settings.json                 ← hooks configurados
    ├── rules/
    │   ├── no-hallucination.md
    │   ├── spec-enforcement.md
    │   └── testing.md
    └── hooks/
        ├── inject-spec.sh            ← UserPromptSubmit: injeta invariantes + cabeçalho visível
        ├── check-spec-before-commit.sh ← PreToolUse/Bash: barra commit se spec/coverage/testes falharem
        ├── spec-coverage.sh          ← auditoria universal I<n> ↔ tests/
        └── hooks.log                 ← log verboso de tudo que os hooks fazem (gerado em runtime)
```

## Hooks: universais + verbosos

Todos os hooks foram desenhados para funcionar em **qualquer stack** (HTML puro, TS, Python, Go, Rust, …) e para deixar rastro visível:

- `inject-spec.sh` sempre emite um cabeçalho `🔧 [hook:inject-spec ✓ HH:MM:SS] N invariantes …` no `additionalContext`. Mesmo em skip (sem `.spec.md` ou sem invariantes) o agente vê que o hook rodou.
- `check-spec-before-commit.sh` **não depende de stack**: primeiro roda `spec-coverage.sh` (baseline universal). Se detectar `package.json`, `pyproject.toml`, `go.mod` ou `Cargo.toml`, roda o runner correspondente como bônus. Em sucesso, retorna `permissionDecision: "allow"` com um relatório — o agente vê ✅ e o log. Em falha, `deny` com o motivo detalhado.
- `spec-coverage.sh` valida que cada `I<n>` da `.spec.md` tem correspondência em `tests/` no formato `I<n> —`. Funciona com checklists em Markdown, testes em qualquer linguagem, snapshots — só precisa da convenção de nome.
- Todos escrevem em `.claude/hooks/hooks.log` com timestamp. Acompanhe em tempo real com `tail -f .claude/hooks/hooks.log`.

## Passo a passo (execute nesta ordem)

1. **Confirme o CWD.** Rode `pwd` pra provar em qual pasta está. Se for `$HOME` ou algum lugar não-projeto, pergunte ao usuário antes de continuar.

2. **Detecte colisão.** Se `.spec.md`, `CLAUDE.md`, ou `.claude/` já existirem no CWD, PARE e pergunte ao usuário: sobrescrever, mesclar, ou abortar. Nunca sobrescreva silenciosamente.

3. **Crie a estrutura de diretórios.** Use um único comando:
   ```bash
   mkdir -p .claude/rules .claude/hooks
   ```

4. **Copie os templates.** Os templates ficam em `$CLAUDE_PLUGIN_ROOT/templates/` (ou onde o skill foi instalado). Copie preservando o layout:
   ```bash
   SKILL_ROOT="<caminho onde este skill foi resolvido>"
   cp "$SKILL_ROOT/templates/.spec.md" .
   cp "$SKILL_ROOT/templates/CLAUDE.md" .
   cp "$SKILL_ROOT/templates/.claude/settings.json" .claude/
   cp "$SKILL_ROOT/templates/.claude/rules/"*.md .claude/rules/
   cp "$SKILL_ROOT/templates/.claude/hooks/"*.sh .claude/hooks/
   ```

   Se você não conseguir descobrir o `$SKILL_ROOT` de forma confiável, use os templates inline (lidos com Read do próprio diretório do skill).

5. **Torne os hooks executáveis.**
   ```bash
   chmod +x .claude/hooks/*.sh
   ```

6. **Confirme.** Rode `ls -la` na raiz e em `.claude/` pra provar que tudo está lá. Nunca reporte sucesso sem verificar.

7. **Explique o próximo passo ao usuário.** Diga em 3 linhas:
   - Editar `.spec.md` com os requisitos reais (o template tem `TODO`).
   - Ajustar `CLAUDE.md` com a stack técnica do projeto (linguagem, testes).
   - Reiniciar o Claude Code na pasta pra os hooks entrarem em vigor (ou abrir `/hooks`).

## Regras de execução

- **Nunca crie o projeto dentro de outro diretório.** Trabalhe no CWD onde a skill foi invocada.
- **Nunca invente conteúdo dos templates.** Se o template não existir em disco, pare e diga que o skill está mal instalado. Não improvise.
- **Nunca marque como pronto antes de verificar com `ls`.** A pasta pode ter sido bloqueada por permissão silenciosamente.
- **Nunca instale dependências** (`npm install`, `pip install`). O harness é agnóstico de linguagem. O usuário decide a stack depois.
