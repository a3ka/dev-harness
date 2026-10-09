# Профиль батареи для scripts/orch_checkpoint.sh + orch_status.sh (контракт 092,
# инвариант И-9). Проверяет, что субъект — чистый парсер (041): не множит
# интерпретацию вводов, не роняет значения, различает разделители.
# Self-application: резолвер работает на собственных входах 041,
# а батарея судит, что дрейфа нет.
PR_SUBJ="$(cd "$HERE/../.." && pwd -P)/scripts/orch_checkpoint.sh"

# ── строители toy-мира ────────────────────────────────────────────────────────
layer_make() { # $1=каталог слоя
  mkdir -p "$1/registry"
  printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":[],"optional":[]}}}' > "$1/registry/harness-project.json"
}
repo_make() { # $1=каталог репо, $2=extra-json-fragment для репо-слоя (или "")
  local extra="$2"
  if [ -z "$extra" ]; then
    extra_frag=''
  else
    extra_frag=",$extra"
  fi
  mkdir -p "$1/config"
  printf '{"schemaVersion":1,"repoId":"r1","language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":[],"optional":[]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}' > "$1/harness.project.json"
  : > "$1/ci.yml"
}

battery_delimiter_collision() {
  local w
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_orc_dc.XXXXXX")"
  layer_make "$w/layer"
  repo_make "$w/repo" '"injected":"v"'
  local out rc
  out="$(ORCH_STATE_DIR="$w/state" mkdir -p "$w/state" 2>&1; ORCH_STATE_DIR="$w/state" bash "$PR_SUBJ" put task "task-with-injected:colon" 2>&1)"; rc=$?
  rm -rf "$w"
  [ "$rc" -eq 0 ] || return 1
  # Прочитать state.tsv и убедиться, что значение с двоеточием — там (а не было
  # расщеплено по разделителю).
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_orc_dc2.XXXXXX")"
  mkdir -p "$w/state"
  ORCH_STATE_DIR="$w/state" bash "$PR_SUBJ" put task "task-with-injected:colon" >/dev/null 2>&1
  local v
  v=$(awk -F'\t' '$1=="task" {print $2}' "$w/state/state.tsv" 2>/dev/null)
  rm -rf "$w"
  [ "$v" = "task-with-injected:colon" ] || return 1
  return 0
}

battery_regex_injection() {
  # Спец-символы regex в значении (квадратная скобка, скобки, точка) — должны
  # быть сохранены дословно, не использованы как regex.
  local w
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_orc_ri.XXXXXX")"
  mkdir -p "$w/state"
  local special='abc[def]g.h(i)j{k}l^m$n+o?p*q'
  ORCH_STATE_DIR="$w/state" bash "$PR_SUBJ" put task "$special" >/dev/null 2>&1
  local v
  v=$(awk -F'\t' '$1=="task" {print $2}' "$w/state/state.tsv" 2>/dev/null)
  rm -rf "$w"
  [ "$v" = "$special" ] || return 1
  return 0
}

battery_silent_drop() {
  # Валидный ввод (по алфавиту) — субъект ДОЛЖЕН принять и записать. Молчаливый
  # rc=1 (drop) — провал.
  local w
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_orc_sd.XXXXXX")"
  mkdir -p "$w/state"
  local rc
  ORCH_STATE_DIR="$w/state" bash "$PR_SUBJ" put task "T-001" >/dev/null 2>&1
  rc=$?
  local v
  v=$(awk -F'\t' '$1=="task" {print $2}' "$w/state/state.tsv" 2>/dev/null)
  rm -rf "$w"
  [ "$rc" -eq 0 ] || return 1
  [ "$v" = "T-001" ] || return 1
  return 0
}

battery_self_application_green() {
  # Self-application: прогоняем субъект на собственных валидных входах,
  # проверяя, что rc 0 сохраняется на разных разрешённых значениях.
  # Параметр инвариантности — случайные непустые строки своей грамматики.
  local w i task stage
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_orc_self.XXXXXX")"
  mkdir -p "$w/state"
  for i in 1 2 3; do
    case "$i" in
      1) task="T-001"; stage="draft" ;;
      2) task="T-002"; stage="spec" ;;
      3) task="T-003"; stage="implement" ;;
    esac
    ORCH_STATE_DIR="$w/state" bash "$PR_SUBJ" init "$task" - >/dev/null 2>&1 || { rm -rf "$w"; return 1; }
    ORCH_STATE_DIR="$w/state" bash "$PR_SUBJ" put stage "$stage" >/dev/null 2>&1 || { rm -rf "$w"; return 1; }
    # Чтение должно вернуть записанное
    local r1 r2
    r1=$(ORCH_STATE_DIR="$w/state" bash "$PR_SUBJ" get task 2>/dev/null)
    r2=$(ORCH_STATE_DIR="$w/state" bash "$PR_SUBJ" get stage 2>/dev/null)
    [ "$r1" = "$task" ] || { rm -rf "$w"; return 1; }
    [ "$r2" = "$stage" ] || { rm -rf "$w"; return 1; }
  done
  rm -rf "$w"
  return 0
}
