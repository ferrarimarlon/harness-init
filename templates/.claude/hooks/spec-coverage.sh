#!/bin/bash
# Script universal: cada invariante I<n> da .spec.md precisa ter pelo menos
# uma referência em `tests/` no formato "I<n> —" (nome de teste, item de
# checklist manual, etc). Funciona em qualquer stack — só precisa de bash
# e grep. Pode ser chamado manualmente ou pelo pre-commit hook.
#
# Escreve resumo em .claude/hooks/hooks.log para o cronograma de auditoria.

set -u
SPEC=".spec.md"
TESTS_DIR="tests"
LOG=".claude/hooks/hooks.log"
STAMP=$(date +"%Y-%m-%d %H:%M:%S")

mkdir -p "$(dirname "$LOG")" 2>/dev/null || true
audit() { printf '[%s] [spec-coverage] %s\n' "$STAMP" "$1" >> "$LOG"; }

if [ ! -f "$SPEC" ]; then
  echo "🔧 [spec-coverage ✗ ${STAMP}] .spec.md não encontrado."
  audit "FAIL (sem .spec.md)"
  exit 1
fi

if [ ! -d "$TESTS_DIR" ]; then
  echo "🔧 [spec-coverage ✗ ${STAMP}] pasta ${TESTS_DIR}/ não existe."
  audit "FAIL (sem $TESTS_DIR/)"
  exit 1
fi

ALL=$(grep -oE "I[0-9]+" "$SPEC" | sort -u)
TOTAL=$(printf '%s\n' "$ALL" | grep -c "^I" || true)
MISSING=""
COVERED=0
for INV in $ALL; do
  if grep -rq "$INV —" "$TESTS_DIR" 2>/dev/null; then
    COVERED=$((COVERED + 1))
  else
    MISSING="$MISSING $INV"
  fi
done

if [ -n "$MISSING" ]; then
  MSG="🔧 [spec-coverage ✗ ${STAMP}] ${COVERED}/${TOTAL} invariantes cobertas. Faltando:${MISSING}"
  echo "$MSG"
  printf '\n%s\n\n' "$MSG" >&2
  audit "FAIL (${COVERED}/${TOTAL}; falta:${MISSING})"
  jq -n --arg ctx "$MSG" --arg msg "$MSG" '{
    hookSpecificOutput: { hookEventName: "UserPromptSubmit", additionalContext: $ctx },
    systemMessage: $msg
  }'
  exit 1
fi

MSG="🔧 [spec-coverage ✓ ${STAMP}] ${COVERED}/${TOTAL} invariantes cobertas em ${TESTS_DIR}/."
echo "$MSG"
printf '\n%s\n\n' "$MSG" >&2
audit "OK (${COVERED}/${TOTAL})"
jq -n --arg ctx "$MSG" --arg msg "$MSG" '{
  hookSpecificOutput: { hookEventName: "UserPromptSubmit", additionalContext: $ctx },
  systemMessage: $msg
}'
exit 0
