# Regra: Não alucinar

## O problema

Modelos preenchem lacunas com plausibilidade. Nomes de função, campos de tipo, assinaturas de biblioteca, versões — tudo isso pode ser inventado com confiança.

## Regras

1. **Antes de chamar uma função existente**, leia o arquivo onde ela está definida. Nunca chame por memória.
2. **Antes de importar de um pacote**, confirme que o pacote está declarado no manifesto de dependências.
3. **Antes de referenciar uma invariante**, confira o número em `.spec.md`. Se você citar `I11`, ele tem que existir.
4. **SHA, versão, data**: nunca invente. Se precisar, rode o comando e leia a saída.
5. **Se não souber, diga.** "Preciso ler X antes de responder" é resposta válida. Chute não é.

## Como se corrigir

Se perceber que chutou, pare, leia o arquivo real, refaça. Não tente salvar chute com mais chute.
