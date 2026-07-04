# Regra: Enforcement da spec

## Antes de qualquer edição em código de produção

1. Leia `.spec.md`. Sempre. Mesmo achando que já leu.
2. Identifique qual invariante a mudança afeta. Escreva o número no seu plano.
3. Se a mudança não mapeia para nenhuma invariante, ela é feature fora de escopo. Pare e pergunte.

## Antes de qualquer edição em `.spec.md`

1. Mudar a spec é mudar o contrato. Nunca faça sem confirmação explícita do usuário.
2. Se a spec parece errada, proponha em texto, aguarde aprovação, só depois edite.

## Ao adicionar teste

1. Nome do teste começa com o código da invariante: `I3 — rejeita X`.
2. Se você criou uma regra no código sem número, criou uma regra fantasma. Volte, adicione na spec, depois teste.

## Ao commitar

O hook `PreToolUse` no Bash roda a suíte de invariantes antes de deixar `git commit` passar. Se falhar, leia a saída, corrija, refaça. Não desabilite o hook.
