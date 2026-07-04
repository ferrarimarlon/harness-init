# [NOME DO PROJETO] — Regras do Projeto

Este arquivo é carregado a cada sessão e após `/compact`. Antes de qualquer código, leia `.spec.md` na raiz. A spec vence este arquivo se houver conflito.

## Contrato de trabalho

1. **Spec é lei.** Nenhuma linha de código pode contradizer `.spec.md`. Se a spec estiver errada, discuta antes de implementar variação.
2. **Invariantes têm código.** Toda referência a regra usa o número (`I1`, `I7`). Comentário de código que menciona invariante cita o número.
3. **Fluxo esperado retorna resultado tipado.** Exceção é bug do runtime, não do domínio.
4. **Teste antes de código.** Nova invariante ou mudança de regra: primeiro escreve o teste em `tests/`, depois implementa.

## Stack

TODO: descreva a stack técnica do projeto (linguagem, versão, framework de teste, comandos).

Exemplo:
- Linguagem: TypeScript strict, Node 20+
- Testes: Vitest, rodar com `npm test`
- Typecheck: `npm run typecheck`
- Cobertura de spec: `npm run spec:check`

## Regras modulares

Também leia:

- `.claude/rules/no-hallucination.md`
- `.claude/rules/spec-enforcement.md`
- `.claude/rules/testing.md`

## Sobre a auto-memória

O `MEMORY.md` deste projeto vive em `~/.claude/projects/<caminho-encodado>/memory/MEMORY.md`, criado automaticamente pelo Claude Code. Não é um arquivo do repositório. Audite com `/memory` antes de sessão crítica.

## O que NÃO fazer

- Não crie arquivos README, docs ou exemplos sem pedido explícito.
- Não adicione feature além da spec. Se sentir que falta algo, proponha edição da spec, não da implementação.
- Não silencie erro de tipo com casts irrestritos.
