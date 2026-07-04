#!/bin/bash
# UserPromptSubmit: injeta as invariantes da .spec.md em cada turno E emite um
# cabeçalho visível de "hook rodou" para que o agente e o usuário saibam que
# o harness está vivo. Também escreve em .claude/hooks/hooks.log para inspeção
# posterior com: tail -f .claude/hooks/hooks.log
#
# Universal (agnóstico de stack) — só depende de bash, grep, sed, jq.

set -u
SPEC=".spec.md"
LOG=".claude/hooks/hooks.log"
STAMP=$(date +"%Y-%m-%d %H:%M:%S")

mkdir -p "$(dirname "$LOG")" 2>/dev/null || true
log() { printf '[%s] [inject-spec] %s\n' "$STAMP" "$1" >> "$LOG"; }

emit_ctx() {
  # Sempre emite JSON válido — mesmo em skip — para o usuário/agente verem
  # que o hook rodou. systemMessage aparece como banner visível no CLI.
  jq -n --arg ctx "$1" --arg msg "$2" '{
    hookSpecificOutput: {
      hookEventName: "UserPromptSubmit",
      additionalContext: $ctx
    },
    systemMessage: $msg
  }'
}

if [ ! -f "$SPEC" ]; then
  log "SKIP (sem .spec.md)"
  emit_ctx "🔧 [hook:inject-spec ✓ ${STAMP}] SKIP — .spec.md não encontrado. Log: ${LOG}" \
           "🔧 inject-spec: SKIP — .spec.md não encontrado"
  exit 0
fi

INVARIANTS=$(grep -E "^- \*\*I[0-9]+" "$SPEC" | sed 's/^- \*\*/- /' | sed 's/\*\*//g')
COUNT=$(printf '%s\n' "$INVARIANTS" | grep -c "^- I" || true)

if [ -z "$INVARIANTS" ] || [ "$COUNT" -eq 0 ]; then
  log "SKIP (sem invariantes na spec)"
  emit_ctx "🔧 [hook:inject-spec ✓ ${STAMP}] .spec.md sem invariantes I<n>. Log: ${LOG}" \
           "🔧 inject-spec: .spec.md sem invariantes I<n>"
  exit 0
fi

log "OK (${COUNT} invariantes)"

HEADER="🔧 [hook:inject-spec ✓ ${STAMP}] ${COUNT} invariantes lidas de .spec.md. Log: ${LOG}"
CONTEXT="${HEADER}

Invariantes ativas da spec (referência rápida — leia .spec.md para detalhes):
${INVARIANTS}"

# Imprime no stderr para aparecer visualmente no chat do Claude Code
printf '\n%s\n\nInvariantes ativas da spec:\n%s\n\n' "$HEADER" "$INVARIANTS" >&2

emit_ctx "$CONTEXT" "🔧 inject-spec: ${COUNT} invariantes injetadas de .spec.md"
