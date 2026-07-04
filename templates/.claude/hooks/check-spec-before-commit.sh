#!/bin/bash
# PreToolUse/Bash: em `git commit`, valida o harness de forma UNIVERSAL
# (agnóstica de stack). Sempre roda `spec-coverage.sh` — que só depende da
# convenção I<n> na spec/tests. Se detectar um runner de teste conhecido,
# também roda a suíte, mas o baseline funciona em qualquer projeto.
#
# Verbosidade: tudo é registrado em .claude/hooks/hooks.log e, em caso de
# falha, o `permissionDecisionReason` traz o log detalhado de volta pro
# agente. Acompanhe em tempo real com:
#   tail -f .claude/hooks/hooks.log

set -u
INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')

# Só age em git commit; caso contrário, no-op silencioso.
if ! printf '%s' "$CMD" | grep -qE '(^|[[:space:]&|;])git[[:space:]]+commit'; then
  exit 0
fi

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT" || exit 0

LOG=".claude/hooks/hooks.log"
STAMP=$(date +"%Y-%m-%d %H:%M:%S")
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true
log() { printf '[%s] [pre-commit] %s\n' "$STAMP" "$1" >> "$LOG"; }

log "START (cmd=$(printf '%s' "$CMD" | tr '\n' ' ' | cut -c1-120))"

FAILED=""
REPORT=""

# --- 1. Cobertura universal de invariantes ------------------------------
if [ -x .claude/hooks/spec-coverage.sh ]; then
  COV_OUT=$(bash .claude/hooks/spec-coverage.sh 2>&1)
  COV_STATUS=$?
  REPORT="[spec-coverage] (exit=$COV_STATUS)
$COV_OUT"
  if [ $COV_STATUS -ne 0 ]; then
    FAILED="1"
    log "spec-coverage FAIL"
  else
    log "spec-coverage OK"
  fi
else
  REPORT="[spec-coverage] SKIP (script ausente em .claude/hooks/spec-coverage.sh)"
  log "spec-coverage SKIP"
fi

# --- 2. Runner de teste, se stack conhecida (opcional) ------------------
TEST_CMD=""
if [ -f package.json ] && grep -q '"test"' package.json; then
  TEST_CMD="npm test --silent"
elif [ -f pyproject.toml ] || [ -f pytest.ini ]; then
  TEST_CMD="pytest -q"
elif [ -f go.mod ]; then
  TEST_CMD="go test ./..."
elif [ -f Cargo.toml ]; then
  TEST_CMD="cargo test --quiet"
fi

if [ -n "$TEST_CMD" ]; then
  T_OUT=$(eval "$TEST_CMD" 2>&1)
  T_STATUS=$?
  REPORT="${REPORT}

[tests: ${TEST_CMD}] (exit=${T_STATUS})
$(printf '%s\n' "$T_OUT" | tail -40)"
  if [ $T_STATUS -ne 0 ]; then
    FAILED="1"
    log "tests FAIL ($TEST_CMD)"
  else
    log "tests OK ($TEST_CMD)"
  fi
else
  REPORT="${REPORT}

[tests] SKIP (sem runner detectado — projeto sem package.json/pyproject.toml/go.mod/Cargo.toml)"
  log "tests SKIP (sem runner)"
fi

# --- 3. Decisão --------------------------------------------------------
if [ -n "$FAILED" ]; then
  log "DENY"
  REASON="🚫 [hook:pre-commit ${STAMP}] Commit bloqueado.

${REPORT}

Log completo: ${LOG}"
  jq -n --arg reason "$REASON" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
fi

log "OK"
# Sucesso: também emite um allow com nota de auditoria (o agente vê que
# rodou e passou). Sem isso, sucesso ficaria invisível.
REASON="✅ [hook:pre-commit ✓ ${STAMP}] Harness OK.

${REPORT}

Log: ${LOG}"
jq -n --arg reason "$REASON" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "allow",
    permissionDecisionReason: $reason
  }
}'
exit 0
