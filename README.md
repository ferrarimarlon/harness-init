# harness-init

`harness-init` é uma skill Cursor/Claude que prepara um projeto para desenvolvimento assistido por agente com mais confiabilidade. Ela instala a camada de controle que deve existir antes do código da aplicação.

A skill cria um harness guiado por especificação, com regras de projeto, orientações modulares para o Claude e hooks que mantêm invariantes, testes e commits alinhados.

## Quando Usar

Use esta skill para:

- Inicializar um harness de confiabilidade em um projeto existente.
- Criar a estrutura para um fluxo de engenharia spec-first.
- Preparar um projeto para Claude Code ou desenvolvimento assistido por agente.
- Adicionar hooks universais antes do início da implementação.

Exemplos de prompts:

- "monta o harness aqui"
- "inicializa a estrutura da aula"
- "sobe o controle antes de codar"
- "prepara esse projeto pro Claude Code"
- "cria a stack de engenharia confiável"

## O Que Ela Cria

A skill escreve os arquivos no diretório de trabalho atual.

```text
./
├── .spec.md
├── CLAUDE.md
└── .claude/
    ├── settings.json
    ├── rules/
    │   ├── no-hallucination.md
    │   ├── spec-enforcement.md
    │   └── testing.md
    └── hooks/
        ├── inject-spec.sh
        ├── check-spec-before-commit.sh
        ├── spec-coverage.sh
        └── hooks.log
```

### Arquivos Gerados

- `.spec.md`: template de contrato para o usuário preencher com requisitos e invariantes reais.
- `CLAUDE.md`: orientação de nível de projeto que referencia as regras modulares.
- `.claude/settings.json`: configuração de hooks do Claude Code.
- `.claude/rules/*.md`: regras reutilizáveis para prevenção de alucinação, aplicação da spec e testes.
- `.claude/hooks/*.sh`: hooks shell universais para injeção de contexto, checagens de commit e cobertura da spec.
- `.claude/hooks/hooks.log`: log verboso de runtime gerado pelos hooks.

## Comportamento Dos Hooks

Os hooks são agnósticos de stack e funcionam com HTML puro, TypeScript, Python, Go, Rust e outros tipos de projeto.

- `inject-spec.sh` injeta contexto visível de invariantes no prompt do agente. Ele informa quando roda, mesmo quando não existe `.spec.md` ou não há invariantes.
- `check-spec-before-commit.sh` bloqueia commits quando a cobertura da spec ou os runners de teste disponíveis falham. Ele detecta arquivos comuns de stack, como `package.json`, `pyproject.toml`, `go.mod` e `Cargo.toml`.
- `spec-coverage.sh` verifica se cada invariante `I<n>` em `.spec.md` tem uma entrada correspondente em `tests/` usando a convenção de nome `I<n> -`.
- Todos os hooks escrevem logs com timestamp em `.claude/hooks/hooks.log`.

## Uso

Execute a skill a partir da raiz do projeto.

1. Confirme o diretório de trabalho atual com `pwd`.
2. Se `.spec.md`, `CLAUDE.md` ou `.claude/` já existirem, decida se o caminho correto é sobrescrever, mesclar ou abortar.
3. Crie os diretórios do harness:

```bash
mkdir -p .claude/rules .claude/hooks
```

4. Copie os templates da instalação da skill para a raiz do projeto:

```bash
SKILL_ROOT="<path-to-this-skill>"
cp "$SKILL_ROOT/templates/.spec.md" .
cp "$SKILL_ROOT/templates/CLAUDE.md" .
cp "$SKILL_ROOT/templates/.claude/settings.json" .claude/
cp "$SKILL_ROOT/templates/.claude/rules/"*.md .claude/rules/
cp "$SKILL_ROOT/templates/.claude/hooks/"*.sh .claude/hooks/
```

5. Torne os hooks executáveis:

```bash
chmod +x .claude/hooks/*.sh
```

6. Verifique o resultado com `ls -la` na raiz do projeto e dentro de `.claude/`.

## Depois Da Instalação

Depois que o harness for criado:

- Edite `.spec.md` e substitua o conteúdo `TODO` do template por requisitos reais do projeto.
- Atualize `CLAUDE.md` com a stack técnica real, comandos de teste e convenções do projeto.
- Reinicie o Claude Code na pasta do projeto, ou abra `/hooks`, para que a configuração de hooks entre em vigor.

## Regras De Segurança

- Trabalhe no diretório atual do projeto.
- Sobrescreva `.spec.md`, `CLAUDE.md` ou `.claude/` apenas com confirmação do usuário.
- Use somente os templates reais da skill. Templates ausentes indicam instalação inválida.
- Verifique os arquivos gerados antes de reportar sucesso.
- Deixe dependências fora desta skill. O harness é agnóstico de linguagem.
