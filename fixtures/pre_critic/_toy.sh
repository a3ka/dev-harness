# Каркас семьи pre_critic (контракт 072): строит toy-мир с копиями реальных
# гейтов и проверяет scripts/pre_critic.sh на нём. Семья — «честный минимум»
# для verify_antiplacebo (нужны ЗЕЛЁНЫЕ контрольные прогоны); полные стабы
# и ноги (а)/(б)/(в) судит другая батарея (fixtures/dver_pered_kritikom/
# red_dver_pred_kritikom_072.sh).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd -P)"
SUBJ="$REPO/scripts/pre_critic.sh"

LAST_OUT=''; LAST_RC=0
run_subject() {  # <корень> <рел-путь-контракта>
  local root="$1" rel="$2"
  LAST_OUT="$(cd / && env bash "$SUBJ" "$rel" 2>&1)"
  LAST_RC=$?
}

refuse() {  # <имя-входа> <фраза>
  local gate="$1" phrase="$2"
  [ "$LAST_RC" -eq 1 ] || { printf 'ОТКАЗ: %s: rc %s (ожидался 1)\nвывод:\n%s\n' "$gate" "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
  printf '%s\n' "$LAST_OUT" | grep -Fq "$phrase" || { printf 'ОТКАЗ: %s: причина не названа дословно «%s»:\n%s\n' "$gate" "$phrase" "$LAST_OUT" >&2; exit 1; }
  printf '%s: отказ rc 1, причина названа дословно\n' "$gate" >&2
}

accept() {  # <имя-входа>
  local gate="$1"
  [ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: %s: rc %s (ожидался 0)\nвывод:\n%s\n' "$gate" "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
  printf '%s\n' "$LAST_OUT" | grep -Fq 'КРИТИК: дверь зелёная' || { printf 'ОТКАЗ: %s: нет строки КРИТИК:\n%s\n' "$gate" "$LAST_OUT" >&2; exit 1; }
  printf '%s: rc 0, дверь зелёная\n' "$gate" >&2
}

# mk_toy_repo <каталог>: git-репозиторий + копии реальных гейтов +
# безаргументный package.json + минимальный ci.yml + ci_parity_exceptions.
# Совпадает по форме с toy_make из батареи 072, чтобы контракт-путь
# резолвился из toy-корня.
mk_toy_repo() {
  local d="$1"
  mkdir -p "$d/scripts" "$d/contracts" "$d/.github/workflows" "$d/config"
  cp "$REPO/scripts/check_precision_gate.sh" "$REPO/scripts/check_spec_ready.sh" "$REPO/scripts/verify_ci_parity.sh" "$d/scripts/"
  cp "$REPO/scripts/lib_"*.sh "$d/scripts/"
  cat > "$d/package.json" <<JSON
{
  "name": "toy",
  "version": "1.0.0",
  "scripts": {
    "check:precision-gate": "bash scripts/check_precision_gate.sh",
    "check:spec-ready": "bash scripts/check_spec_ready.sh"
  }
}
JSON
  cat > "$d/.github/workflows/ci.yml" <<'YML'
name: toy-ci
on: [push]
jobs:
  toy:
    runs-on: ubuntu-latest
    steps:
      - run: npm run check:precision-gate -- . contracts/043-toy-draft.md
      - run: npm run check:spec-ready -- . contracts/043-toy-draft.md
YML
  : > "$d/config/ci_parity_exceptions.txt"
  git -C "$d" init -q -b main
  git -C "$d" config user.name orchestrator
  git -C "$d" config user.email orchestrator@dev-harness.local
  git -C "$d" add -A && git -C "$d" commit -qm 'toy: init'
}

: "${BARRIER:=$SUBJ}"