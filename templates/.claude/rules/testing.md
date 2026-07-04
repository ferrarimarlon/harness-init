# Regra: Testes

## Estrutura

- `tests/invariants.*` — um bloco por invariante, com pelo menos um caso positivo e um negativo.
- `fixtures/` — dados fixos reutilizados por múltiplos testes.

## Nomenclatura

`I<n> — <verbo> <cenário>`

Exemplos:
- `I1 — rejeita [violação]`
- `I1 — aceita [caso válido no limite]`
- `I3 — rejeita [cenário limítrofe]`

## O que NÃO fazer

- Nunca `expect(true).toBe(true)`. Teste sem asserção é ruído.
- Nunca mockar tempo global. Passe `now` como argumento para as funções que dependem dele.
- Nunca comentar teste que quebrou. Se quebrou, ou o código está errado, ou o teste está errado, ou a spec está errada. Descubra qual.
