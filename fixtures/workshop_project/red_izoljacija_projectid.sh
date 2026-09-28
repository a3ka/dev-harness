#!/usr/bin/env bash
# 055-БАТАРЕЯ — изоляция состояния по ProjectId + отказ второй сессии +
# метеринг-заголовок + ключ packs (контракт 055, II-2 плана §11).
#
# До-заморозочный адрес — fixtures/check_judge_gate/ (architect-зона по
# ДЕЙСТВУЮЩИМ заморозкам; прецедент 054: red_profil_dva_sloja_054.sh жил
# здесь на круг критика). Дом семьи после заморозки — fixtures/workshop_project/
# + раннер fixtures/_krasnye_055.sh (зоны implementer; перенос первым
# пост-заморозочным коммитом — прецедент 045/054).
#
# Структура (054-прецедент):
#   1. СТАБ-ПАК (9 обманных стабов, ручки STUB_*) — зелёный ДО и ПОСЛЕ
#      реализации: каждый стаб умирает на СВОЕЙ клетке (привязка по коду
#      фикстуры, Н-39); дифференциальная проба — те же стабы БЕЗ ручек
#      проходят свои клетки (ловля предикатом, не случаем).
#   2. ЧЕСТНАЯ ЧАСТЬ (клетки h1..h13) — красная ДО реализации
#      (г0: предмет отсутствует), зелёная ПОСЛЕ.
#
# НАБЛЮДЕНИЕ РЕАЛЬНЫХ ЭКСПОРТОВ ПОТОМКА (критик 055-v1, блокер 1): живой
# режим workshop заканчивается `exec omp` с поиском по PATH — клетки h7/h8
# ставят в PATH СТАБ-OMP (субъект), который пишет факт СВОЕГО окружения
# (env) и свой PID в файлы; проба сверяет все шесть экспортов И-2/И-7
# литеральными строками в этом файле. Баннер и каталоги, выбранные самим
# проверяемым, больше НЕ единственное свидетельство.
#
# ТОЧНЫЕ rc-ПРЕДИКАТЫ (критик 055-v1, блокер 2): каждый негативный вход
# требует rc РОВНО 1 (не «любой отказ») И полную фразу с ФАКТИЧЕСКИМИ
# корнем/PID/значением — rc=7, «wrong-root pid wrong-pid» и усечённый
# диагноз красные. Формат P6 packs — симметричен барьерам 054:
# НЕ-массив → `packs: <тип>` (тип в угловых скобках), элемент → `packs: <элемент>`.
#
# Прогон: bash red_izoljacija_projectid_055.sh [корень worktree]
#   rc 0 — стаб-пак пойман (9/9) И честная часть зелёная (13/13).
#   rc 1 — расхождение / предмет отсутствует (ДО реализации).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="${1:-$(cd "$HERE/../.." && pwd -P)}"
WORKSHOP="$ROOT/workshop"
RESOLVER="$ROOT/scripts/profile_resolver.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
die_pack() { printf '055-батарея ОТКАЗ: %s\n' "$*" >&2; exit 1; }
command -v git >/dev/null 2>&1 || die_pack "нет git"
command -v jq >/dev/null 2>&1 || die_pack "нет jq"
command -v sha256sum >/dev/null 2>&1 || die_pack "нет sha256sum"

# Ложные зелёные от протекающего окружения батареи: субъект обязан
# экспортировать сам — унаследованное не засчитывается.
unset HARNESS_SESSION_HOME HARNESS_SCRATCH METERING_PROJECT METERING_ROLE

W3_TAIL='Вторая сессия на том же корне запрещена (Н-108): заверши её или работай в другом клоне'
w3_line() { printf 'workshop ОТКАЗ: на корне %s уже идёт сессия (pid %s). %s' "$1" "$2" "$W3_TAIL"; }
W4_LINE='workshop ОТКАЗ: projectId вне класса пути: Bad/Id (класс ^[a-z0-9][a-z0-9_-]*$) — правь слой проекта'

# ── строители toy-мира (ПОЛНЫЙ профиль 054 — совет критика 055-v1: toy     ───
# обязан проходить живой резолвер HEAD: defaults барьеров/путей/команд) ──────
layer_make() { # $1=корень слоя $2=projectId
  mkdir -p "$1/registry"
  printf '{"schemaVersion":1,"version":"v10","projectId":"%s","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"cargo test","build":"cargo build","typecheck":"cargo check","lint":"cargo clippy"},"git":{"canonicalRemote":"git@host:p1.git"},"ci":{"workflow":".github/workflows/ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":[]}}}' "$2" > "$1/registry/harness-project.json"
}
repo_make() { # $1=корень репо $2=repoId $3=packs-jq-значение ("-" = ключа нет)
  local r="$1"
  mkdir -p "$r/config"
  git -C "$r" init -q
  git -C "$r" config receive.denyCurrentBranch refuse
  if [ "${3:-}" = "-" ]; then
    printf '{"schemaVersion":1,"repoId":"%s","language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"ci":{"workflow":".github/workflows/ci.yml"},"git":{"canonicalRemote":"git@host:r1.git"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}' "$2" > "$r/harness.project.json"
  else
    printf '{"schemaVersion":1,"repoId":"%s","language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"ci":{"workflow":".github/workflows/ci.yml"},"git":{"canonicalRemote":"git@host:r1.git"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"},"packs":%s}' "$2" "${3:-[]}" > "$r/harness.project.json"
  fi
  printf '{"version":"v10"}\n' > "$r/config/harness_pin.json"
  printf 'METERING_PROXY_URL=http://toy.invalid:1\n' > "$r/.env"
}
root_hash8() { printf '%s' "$(cd "$1" && pwd -P)" | sha256sum | cut -c1-8; }

# ── СТАБ-OMP: субъект живого режима (exec omp ищется в PATH — workshop:724) ─
# Пишет факт СВОЕГО окружения/PID в файлы; --version закрывает сверку пина.
SHIMDIR="$WORK/shimbin"; mkdir -p "$SHIMDIR"
cat > "$SHIMDIR/omp" <<'SHIM'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then printf 'omp/v10\n'; exit 0; fi
printf 'pid=%s\n' "$$" > "$SHIM_OUT"
env | LC_ALL=C sort > "$SHIM_ENV"
if [ -n "${SHIM_SLEEP:-}" ]; then sleep "$SHIM_SLEEP"; fi
exit 0
SHIM
chmod +x "$SHIMDIR/omp"

# ── ОБМАННЫЙ СТАБ лаунчера 055: probe и живой режим; обманывает ровно───────
# одной ручкой STUB_*; без ручек честен на своих клетках (c1..c6).
cat > "$WORK/stub-workshop" <<'STUB'
#!/usr/bin/env bash
set -uo pipefail
probe=0; repo=""
while [ $# -gt 0 ]; do case "$1" in
  --probe) probe=1 ;;
  *) repo="$1" ;;
esac; shift; done
pid_id="$(jq -r '.projectId' "$HARNESS_PROJECT_LAYER_ROOT/registry/harness-project.json")"
# W4: projectId вне класса пути — именованный отказ (И-1); ручка
# STUB_PID_CLASS_BAD подменяет проверку молчаливой нормализацией.
if printf '%s' "$pid_id" | grep -Eqv '^[a-z0-9][a-z0-9_-]*$'; then
  if [ -z "${STUB_PID_CLASS_BAD:-}" ]; then
    printf 'workshop ОТКАЗ: projectId вне класса пути: %s (класс ^[a-z0-9][a-z0-9_-]*$) — правь слой проекта\n' "$pid_id" >&2
    exit 1
  fi
  pid_id="normalized"
fi
base="${TMP_BASE_055:-$XDG_STATE_HOME}"
# Фикс 055-к2 (блокер 3): PSTATE-base обязан быть абсолютным путём ВНЕ
# чекаута. Ручка STUB_RELATIVE_BASE_OK подменяет отказ молчаливым
# использованием относительного пути.
if [ -z "${STUB_RELATIVE_BASE_OK:-}" ]; then
  case "$base" in
    /*) ;;
    *) printf 'workshop ОТКАЗ: PSTATE-base относительный: %s. XDG_STATE_HOME и HARNESS_SCRATCH обязаны быть абсолютным путём ВНЕ чекаута проекта\n' "$base" >&2
       exit 1 ;;
  esac
fi
# s1: state-корень от дев-зоны; s2: projectId проигнорирован (общий state).
if [ -n "${STUB_IGNORE_PROJECTID:-}" ]; then
  pstate="$base/dev-harness-sessions/$(printf '%s' "$base" | sha256sum | cut -c1-8)"
elif [ -n "${STUB_SHARED_STATE:-}" ]; then
  pstate="$base/dev-harness-projects/shared"
else
  pstate="$base/dev-harness-projects/$pid_id"
fi
lock="$pstate/sessions/$(printf '%s' "$(cd "$repo" && pwd -P)" | sha256sum | cut -c1-8).lock"
mkdir -p "$pstate/sessions" "$pstate/home" "$pstate/scratch" "$pstate/state"
# Экспорты И-2/И-7 (наблюдает стаб-omp — субъект; стаб-пак ловит их отсутствием).
export HARNESS_SESSION_HOME="$pstate/home"
export HOME="$pstate/home"
export HARNESS_SCRATCH="$pstate/scratch"
export XDG_STATE_HOME="$pstate/state"
# s6: метеринг-экспорты не происходят.
if [ -z "${STUB_NO_METERING_ENV:-}" ]; then
  export METERING_PROJECT="$pid_id"
  export METERING_ROLE="orchestrator"
fi
# Лок-механика: по умолчанию — атомарный mkdir (как в живом workshop после
# фикса 055-к2). Ручка STUB_RACY_LOCK=1 включает НЕатомарный режим
# (printf в файл) для проверки различимости и для сценария c13.
if [ -n "${STUB_RACY_LOCK:-}" ]; then
  # Неатомарная (racy) логика с регулярным файлом
  if [ -f "$lock" ]; then
    lpid="$(cat "$lock" 2>/dev/null || true)"
    alive=0
    case "$lpid" in
      ''|*[!0-9]*) alive=0 ;;
      *) kill -0 "$lpid" 2>/dev/null && alive=1 || alive=0 ;;
    esac
    if [ "$alive" = 1 ] && [ -z "${STUB_NO_LOCK:-}" ]; then
      printf 'workshop ОТКАЗ: на корне %s уже идёт сессия (pid %s). Вторая сессия на том же корне запрещена (Н-108): заверши её или работай в другом клоне\n' "$(cd "$repo" && pwd -P)" "$lpid" >&2
      exit 1
    fi
    if [ "$alive" = 0 ] && [ -n "${STUB_STALE_REFUSAL:-}" ]; then
      printf 'workshop ОТКАЗ: на корне %s уже идёт сессия (pid %s). Вторая сессия на том же корне запрещена (Н-108): заверши её или работай в другом клоне\n' "$(cd "$repo" && pwd -P)" "$lpid" >&2
      exit 1
    fi
  fi
  if [ "$probe" = 1 ]; then
    printf 'workshop PROBE OK: %s\n' "$repo"
    printf 'PROMPT: %s/session-prompt-orchestrator.md\n' "$pstate/home"
    printf 'STATE: %s\n' "$pstate"
    if [ -z "${STUB_NO_METERING_ENV:-}" ]; then
      printf 'METERING: project=%s role=%s\n' "$pid_id" "orchestrator"
    fi
    # s5: probe занимает лок.
    [ -n "${STUB_PROBE_HOLDS_LOCK:-}" ] && printf '%s\n' "$$" > "$lock"
    exit 0
  fi
  # Живой режим: лок с $$ ДО exec (PID переживает exec — стаб-omp видит тот же PID).
  printf '%s\n' "$$" > "$lock"
  exec omp --profile toy-stub --model toy-stub
else
  # Атомарная логика через mkdir (фикс 055-к2)
  if [ -d "$lock" ]; then
    lpid="$(cat "$lock/pid" 2>/dev/null || true)"
    alive=0
    case "$lpid" in
      ''|*[!0-9]*) alive=0 ;;
      *) kill -0 "$lpid" 2>/dev/null && alive=1 || alive=0 ;;
    esac
    if [ "$alive" = 1 ] && [ -z "${STUB_NO_LOCK:-}" ]; then
      printf 'workshop ОТКАЗ: на корне %s уже идёт сессия (pid %s). Вторая сессия на том же корне запрещена (Н-108): заверши её или работай в другом клоне\n' "$(cd "$repo" && pwd -P)" "$lpid" >&2
      exit 1
    fi
    if [ "$alive" = 0 ] && [ -n "${STUB_STALE_REFUSAL:-}" ]; then
      printf 'workshop ОТКАЗ: на корне %s уже идёт сессия (pid %s). Вторая сессия на том же корне запрещена (Н-108): заверши её или работай в другом клоне\n' "$(cd "$repo" && pwd -P)" "$lpid" >&2
      exit 1
    fi
    rm -rf "$lock" 2>/dev/null || true
  fi
  if [ "$probe" = 1 ]; then
    printf 'workshop PROBE OK: %s\n' "$repo"
    printf 'PROMPT: %s/session-prompt-orchestrator.md\n' "$pstate/home"
    printf 'STATE: %s\n' "$pstate"
    if [ -z "${STUB_NO_METERING_ENV:-}" ]; then
      printf 'METERING: project=%s role=%s\n' "$pid_id" "orchestrator"
    fi
    # s5: probe занимает лок (атомарно).
    if [ -n "${STUB_PROBE_HOLDS_LOCK:-}" ]; then
      mkdir "$lock" 2>/dev/null && printf '%s\n' "$$" > "$lock/pid"
    fi
    exit 0
  fi
  # Живой режим: атомарный mkdir перед exec.
  if ! mkdir "$lock" 2>/dev/null; then
    if [ -f "$lock/pid" ]; then
      lpid2="$(cat "$lock/pid" 2>/dev/null || true)"
      case "$lpid2" in
        ''|*[!0-9]*) ;;
        *) if kill -0 "$lpid2" 2>/dev/null; then
          printf 'workshop ОТКАЗ: на корне %s уже идёт сессия (pid %s). Вторая сессия на том же корне запрещена (Н-108): заверши её или работай в другом клоне\n' "$(cd "$repo" && pwd -P)" "$lpid2" >&2
          exit 1
        fi ;;
      esac
    fi
    printf 'workshop ОТКАЗ: атомарный захват PID-лока не удался: %s\n' "$lock" >&2
    exit 1
  fi
  printf '%s\n' "$$" > "$lock/pid"
  exec omp --profile toy-stub --model toy-stub
fi
STUB
chmod +x "$WORK/stub-workshop"

# ── ОБМАННЫЙ СТАБ резолвера 055: packs-семантика; обман одной ручкой ────────
cat > "$WORK/stub-resolver" <<'STUB'
#!/usr/bin/env bash
set -uo pipefail
repo=""
while [ $# -gt 0 ]; do case "$1" in --repo) repo="${2:-}"; shift ;; *) repo="$1" ;; esac; shift; done
[ -f "$repo/harness.project.json" ] || { printf 'profile ОТКАЗ: нет harness.project.json: %s/harness.project.json\n' "$repo" >&2; exit 1; }
ptype="$(jq -r 'if has("packs") then (.packs | type) else "missing" end' "$repo/harness.project.json" 2>/dev/null || echo missing)"
if [ "$ptype" != "array" ] && [ "$ptype" != "missing" ]; then
  if [ -z "${STUB_PACKS_NONLIST_OK:-}" ]; then
    printf 'profile ОТКАЗ: значение вне алфавита: packs: <%s>\n' "$ptype" >&2
    exit 1
  fi
fi
if [ "$ptype" = "array" ]; then
  # Фикс 055-к2 (блокер 1): пустой элемент `[""]` и `["\n"]` молча
  # принимались. Ручка STUB_PACKS_EMPTY_OK=1 делает вид, что пустой
  # элемент не найден (имитирует прежний баг резолвера). Без ручки —
  # нормальный отказ.
  #
  # Используем `length` массива плохих элементов: для пустого/переводного
  # элемента длина массива >0, но `$()` стирает из строки trailing-newline,
  # а сам `select(... | not)` для пустой строки выдаёт пустую строку
  # (одна пустая строка в выводе), которая после head -n 1 + $() = "".
  # Маркер «EMPTY_MARKER» в первом плохом элементе делает пустую строку
  # отличимой от «не нашли ничего». Пробельные элементы (только \n, \t,
  # пробелы) тоже маппятся в EMPTY_MARKER — они семантически пусты для
  # packs-алфавита `^[a-z0-9][a-z0-9_-]*$`.
  local bad_count first_bad
  if [ -z "${STUB_PACKS_EMPTY_OK:-}" ]; then
    bad_count="$(jq -r '[.packs[] | select(test("^[a-z0-9][a-z0-9_-]*$") | not)] | length' "$repo/harness.project.json" 2>/dev/null || echo 0)"
  else
    bad_count="$(jq -r '[.packs[] | select((. != "") and (test("^[a-z0-9][a-z0-9_-]*$") | not))] | length' "$repo/harness.project.json" 2>/dev/null || echo 0)"
  fi
  if [ "${bad_count:-0}" -gt 0 ]; then
    if [ -z "${STUB_PACKS_ELEM_OK:-}" ]; then
      first_bad="$(jq -r '[.packs[] | select(test("^[a-z0-9][a-z0-9_-]*$") | not) | if (. | test("^\\s*$")) then "EMPTY_MARKER" else . end][0] // "EMPTY_MARKER"' "$repo/harness.project.json" 2>/dev/null || echo EMPTY_MARKER)"
      if [ "$first_bad" = "EMPTY_MARKER" ]; then
        printf 'profile ОТКАЗ: значение вне алфавита: packs: пусто\n' >&2
      else
        printf 'profile ОТКАЗ: значение вне алфавита: packs: %s\n' "$first_bad" >&2
      fi
      exit 1
    fi
  fi
fi
out="$(jq -c '. + {packs: {value: (.packs // []), origin: (if has("packs") then "repo" else "project" end)}}' "$repo/harness.project.json")"
if [ -n "${STUB_PACKS_MISSING_OK:-}" ]; then
  out="$(printf '%s' "$out" | jq -c 'del(.packs)')"
fi
printf '%s\n' "$out"
exit 0
STUB
chmod +x "$WORK/stub-resolver"

# ── стаб-пак: клетки c1..c9, каждая ловит СВОЙ стаб; счёт напечатан ─────────
CAUGHT=0; SEEN=0
LAYER="$WORK/layer-p1"; layer_make "$LAYER" p1; R1="$WORK/repo-p1"; repo_make "$R1" r1 -
LAYER2="$WORK/layer-p2"; layer_make "$LAYER2" p2; R2="$WORK/repo-p2"; repo_make "$R2" r2 -
SLOCK="$WORK/base/dev-harness-projects/p1/sessions/$(root_hash8 "$R1").lock"
stub_live() { # $1=база дампа; живой прогон стаба (p1), субъект пишет факт env
  local db="$1"
  rm -rf "$SLOCK" 2>/dev/null
  env PATH="$SHIMDIR:$PATH" TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    SHIM_ENV="$db.env" SHIM_OUT="$db.pid" "$WORK/stub-workshop" "$R1" >/dev/null 2>&1
}
P1HOME_LINE="HOME=$WORK/base/dev-harness-projects/p1/home"
check_c1() { # s1: экспортированный HOME уведён в дев-зону мастерской
  rm -rf "$SLOCK" 2>/dev/null
  env PATH="$SHIMDIR:$PATH" TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    SHIM_ENV="$WORK/d1.env" SHIM_OUT="$WORK/d1.pid" STUB_IGNORE_PROJECTID=1 \
    "$WORK/stub-workshop" "$R1" >/dev/null 2>&1
  grep -Fxq "$P1HOME_LINE" "$WORK/d1.env" 2>/dev/null \
    && ! grep -Eq '^(HOME|HARNESS_SESSION_HOME|HARNESS_SCRATCH|XDG_STATE_HOME)=.*dev-harness-sessions' "$WORK/d1.env" 2>/dev/null && return 1
  return 0
}
diff_c1() {
  stub_live "$WORK/d1"
  grep -Fxq "$P1HOME_LINE" "$WORK/d1.env" 2>/dev/null \
    && ! grep -Eq '^(HOME|HARNESS_SESSION_HOME|HARNESS_SCRATCH|XDG_STATE_HOME)=.*dev-harness-sessions' "$WORK/d1.env" 2>/dev/null
}
check_c2() { # s2: общий экспортированный HOME у двух проектов
  rm -rf "$SLOCK" 2>/dev/null
  env PATH="$SHIMDIR:$PATH" TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    SHIM_ENV="$WORK/d2a.env" SHIM_OUT="$WORK/d2a.pid" STUB_SHARED_STATE=1 "$WORK/stub-workshop" "$R1" >/dev/null 2>&1
  env PATH="$SHIMDIR:$PATH" TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER2" \
    SHIM_ENV="$WORK/d2b.env" SHIM_OUT="$WORK/d2b.pid" STUB_SHARED_STATE=1 "$WORK/stub-workshop" "$R2" >/dev/null 2>&1
  local a b
  a="$(grep -F 'HOME=' "$WORK/d2a.env" 2>/dev/null | grep -F 'dev-harness-projects' | head -n1)"
  b="$(grep -F 'HOME=' "$WORK/d2b.env" 2>/dev/null | grep -F 'dev-harness-projects' | head -n1)"
  [ -n "$a" ] && [ "$a" = "$b" ]
}
diff_c2() {
  stub_live "$WORK/d2a"
  env PATH="$SHIMDIR:$PATH" TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER2" \
    SHIM_ENV="$WORK/d2b.env" SHIM_OUT="$WORK/d2b.pid" "$WORK/stub-workshop" "$R2" >/dev/null 2>&1
  local a b
  a="$(grep -Fx "HOME=$WORK/base/dev-harness-projects/p1/home" "$WORK/d2a.env" 2>/dev/null)"
  b="$(grep -Fx "HOME=$WORK/base/dev-harness-projects/p2/home" "$WORK/d2b.env" 2>/dev/null)"
  [ -n "$a" ] && [ -n "$b" ] && [ "$a" != "$b" ]
}
check_c3() { # s3: живой лок игнорируется в живом режиме (честный rc РОВНО 1)
  mkdir -p "$SLOCK"
  sleep 30 & HOLDER=$!
  printf '%s\n' "$HOLDER" > "$SLOCK/pid"
  local rc=0
  env PATH="$SHIMDIR:$PATH" TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    SHIM_ENV="$WORK/d3.env" SHIM_OUT="$WORK/d3.pid" STUB_NO_LOCK=1 "$WORK/stub-workshop" "$R1" >/dev/null 2>&1 || rc=$?
  kill "$HOLDER" 2>/dev/null; wait "$HOLDER" 2>/dev/null
  [ "$rc" -eq 0 ]
}
diff_c3() { # честный стаб: rc РОВНО 1 и полная фраза W3 с фактическими root/pid
  mkdir -p "$SLOCK"
  sleep 30 & HOLDER=$!
  printf '%s\n' "$HOLDER" > "$SLOCK/pid"
  local out rc=0
  out="$(env PATH="$SHIMDIR:$PATH" TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    SHIM_ENV="$WORK/d3.env" SHIM_OUT="$WORK/d3.pid" "$WORK/stub-workshop" "$R1" 2>&1)"; rc=$?
  kill "$HOLDER" 2>/dev/null; wait "$HOLDER" 2>/dev/null
  [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$(w3_line "$(cd "$R1" && pwd -P)" "$HOLDER")"
}
check_c4() { # s4: мёртвый лок не замещается (честный стаб — rc 0)
  mkdir -p "$SLOCK"
  sleep 30 & DEAD=$!; kill "$DEAD" 2>/dev/null; wait "$DEAD" 2>/dev/null
  printf '%s\n' "$DEAD" > "$SLOCK/pid"
  local rc=0
  env PATH="$SHIMDIR:$PATH" TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    SHIM_ENV="$WORK/d4.env" SHIM_OUT="$WORK/d4.pid" STUB_STALE_REFUSAL=1 "$WORK/stub-workshop" "$R1" >/dev/null 2>&1 || rc=$?
  [ "$rc" -ne 0 ]
}
diff_c4() {
  mkdir -p "$SLOCK"
  sleep 30 & DEAD=$!; kill "$DEAD" 2>/dev/null; wait "$DEAD" 2>/dev/null
  printf '%s\n' "$DEAD" > "$SLOCK/pid"
  env PATH="$SHIMDIR:$PATH" TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    SHIM_ENV="$WORK/d4.env" SHIM_OUT="$WORK/d4.pid" "$WORK/stub-workshop" "$R1" >/dev/null 2>&1
}
check_c5() { # s5: probe занимает лок (атомарно — каталог)
  rm -rf "$SLOCK"
  env TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" STUB_PROBE_HOLDS_LOCK=1 \
    "$WORK/stub-workshop" --probe "$R1" >/dev/null 2>&1
  [ -d "$SLOCK" ]
}
diff_c5() {
  rm -rf "$SLOCK"
  env TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    "$WORK/stub-workshop" --probe "$R1" >/dev/null 2>&1
  [ ! -d "$SLOCK" ]
}
check_c6() { # s6: метеринг-экспорты не доходят до субъекта
  rm -rf "$SLOCK" 2>/dev/null
  env PATH="$SHIMDIR:$PATH" TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    SHIM_ENV="$WORK/d6.env" SHIM_OUT="$WORK/d6.pid" STUB_NO_METERING_ENV=1 \
    "$WORK/stub-workshop" "$R1" >/dev/null 2>&1
  grep -Fxq 'METERING_PROJECT=p1' "$WORK/d6.env" 2>/dev/null \
    && grep -Fxq 'METERING_ROLE=orchestrator' "$WORK/d6.env" 2>/dev/null && return 1
  return 0
}
diff_c6() {
  stub_live "$WORK/d6"
  grep -Fxq 'METERING_PROJECT=p1' "$WORK/d6.env" 2>/dev/null \
    && grep -Fxq 'METERING_ROLE=orchestrator' "$WORK/d6.env" 2>/dev/null
}
R7="$WORK/repo-c7"; repo_make "$R7" r7 -
R8="$WORK/repo-c8"; repo_make "$R8" r8 '"core"'
R9="$WORK/repo-c9"; repo_make "$R9" r9 '["Bad Pack!"]'
# Фикс 055-к2: новые клетки c10..c13 — для каждой находки адверсария.
# R10 — пустой элемент `[""]`; R12 — элемент-перевод `["\n"]`.
R10="$WORK/repo-c10"; repo_make "$R10" r10 '[""]'
R12="$WORK/repo-c12"; repo_make "$R12" r12 '["\n"]'
R11="$WORK/repo-h11"; repo_make "$R11" r11 '["core"]' # положительный массив h11 (круг 3: НЕ строка R8/h12)
# R14, R15 — для честных клеток h14, h15 (тот же packs-сценарий, но против честного резолвера).
R14="$WORK/repo-h14"; repo_make "$R14" rh14 '[""]'
R15="$WORK/repo-h15"; repo_make "$R15" rh15 '["\n"]'
check_c7() { # s7: packs отсутствует → ключ пропущен из вывода
  ! env STUB_PACKS_MISSING_OK=1 "$WORK/stub-resolver" --repo "$R7" 2>/dev/null | jq -e '.packs.value == [] and .packs.origin == "project"' >/dev/null 2>&1
}
diff_c7() { env "$WORK/stub-resolver" --repo "$R7" 2>/dev/null | jq -e '.packs.value == [] and .packs.origin == "project"' >/dev/null 2>&1; }
check_c8() { # s8: НЕ-список packs принят (честный стаб — rc РОВНО 1 с полным P6)
  local rc=0
  env STUB_PACKS_NONLIST_OK=1 "$WORK/stub-resolver" --repo "$R8" >/dev/null 2>&1 || rc=$?
  [ "$rc" -eq 0 ]
}
diff_c8() {
  local o rc=0
  o="$(env "$WORK/stub-resolver" --repo "$R8" 2>&1)"; rc=$?
  [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq 'profile ОТКАЗ: значение вне алфавита: packs: <string>'
}
check_c9() { # s9: элемент вне класса принят (честный стаб — rc РОВНО 1, элемент в причине)
  local rc=0
  env STUB_PACKS_ELEM_OK=1 "$WORK/stub-resolver" --repo "$R9" >/dev/null 2>&1 || rc=$?
  [ "$rc" -eq 0 ]
}
diff_c9() {
  local o rc=0
  o="$(env "$WORK/stub-resolver" --repo "$R9" 2>&1)"; rc=$?
  [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq 'profile ОТКАЗ: значение вне алфавита: packs: Bad Pack!'
}
# ── фикс 055-к2 (адверсарий к1): клетки c10..c13 — к каждой находке по красной клетке
check_c10() { # s10: пустой элемент `[""]` принят (стаб с STUB_PACKS_EMPTY_OK)
  local rc=0
  env STUB_PACKS_EMPTY_OK=1 "$WORK/stub-resolver" --repo "$R10" >/dev/null 2>&1 || rc=$?
  [ "$rc" -eq 0 ]
}
diff_c10() {
  local o rc=0
  o="$(env "$WORK/stub-resolver" --repo "$R10" 2>&1)"; rc=$?
  [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq 'profile ОТКАЗ: значение вне алфавита: packs: пусто'
}
check_c11() { # s11: newline-элемент `["\n"]` принят (стаб с STUB_PACKS_ELEM_OK; тот же путь, что для c9)
  local rc=0
  env STUB_PACKS_ELEM_OK=1 "$WORK/stub-resolver" --repo "$R12" >/dev/null 2>&1 || rc=$?
  [ "$rc" -eq 0 ]
}
diff_c11() {
  local o rc=0
  o="$(env "$WORK/stub-resolver" --repo "$R12" 2>&1)"; rc=$?
  [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq 'profile ОТКАЗ: значение вне алфавита: packs: пусто'
}
check_c12() { # s12: относительный PSTATE-base принят (стаб с STUB_RELATIVE_BASE_OK)
  local rc=0
  rm -rf "$SLOCK" 2>/dev/null
  (cd "$R1" && env XDG_STATE_HOME="relative-state" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    TMP_BASE_055="relative-state" STUB_RELATIVE_BASE_OK=1 \
    "$WORK/stub-workshop" --probe "$R1" >/dev/null 2>&1) || rc=$?
  [ "$rc" -eq 0 ]
}
diff_c12() {
  local out rc=0
  rm -rf "$SLOCK" 2>/dev/null
  out="$(cd "$R1" && env XDG_STATE_HOME="relative-state" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    TMP_BASE_055="relative-state" \
    "$WORK/stub-workshop" --probe "$R1" 2>&1)"; rc=$?
  [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq 'workshop ОТКАЗ: PSTATE-base относительный: relative-state'
}
check_c13() { # s13: минимальный racy-лок против 64 параллельных стартов → больше 1 успеха
  # Контрмодель: НЕ через stub-workshop (тот успевает отрабатывать lock
  # слишком быстро, и race window оказывается уже реального). Используем
  # ТОЛЬКО лок-примитив: проверка + printf в файл с явной задержкой 5мс
  # МЕЖДУ ними — это воспроизводит TOCTOU и гарантирует, что окно race
  # достаточно широкое для 64 одновременных стартов. «Победитель»
  # удерживает лок 15с (sleep), чтобы проигравшие увидели актуальный pid.
  local db="$WORK/c13" i succ=0
  rm -rf "$db" "$WORK/c13.rc."* 2>/dev/null
  mkdir -p "$db"
  for i in $(seq 1 64); do
    (env XDG_STATE_HOME="$db" \
      SHIM_OUT="$db/p.$i" \
      bash -c '
        set -u
        lock="$XDG_STATE_HOME/dev-harness-projects/p1/sessions/lock"
        mkdir -p "$(dirname "$lock")"
        # Race window: TOCTOU между проверкой и записью.
        if [ -f "$lock" ]; then
          lpid="$(cat "$lock" 2>/dev/null || true)"
          if [ -n "$lpid" ] && kill -0 "$lpid" 2>/dev/null; then exit 1; fi
        fi
        # Расширяем окно гонки: 5мс задержки между check и write.
        sleep 0.005
        printf "%s\n" "$$" > "$lock"
        # Удерживаем позицию 15с, чтобы проигравшие увидели живой pid.
        sleep 15
        rm -f "$lock"
        exit 0
      '; \
      printf '%s\n' "$?" > "$WORK/c13.rc.$i") &
  done
  wait
  for i in $(seq 1 64); do
    [ "$(cat "$WORK/c13.rc.$i" 2>/dev/null)" = "0" ] && succ=$((succ+1))
  done
  rm -rf "$db" "$WORK/c13.rc."* 2>/dev/null
  [ "$succ" -gt 1 ]
}
diff_c13() { # атомарный mkdir-лок против 64 параллельных стартов → ровно 1 успех
  local db="$WORK/c13d" i succ=0
  rm -rf "$db" "$WORK/c13d.rc."* 2>/dev/null
  mkdir -p "$db"
  for i in $(seq 1 64); do
    (env XDG_STATE_HOME="$db" \
      SHIM_OUT="$db/p.$i" \
      bash -c '
        set -u
        lock="$XDG_STATE_HOME/dev-harness-projects/p1/sessions/lock"
        mkdir -p "$(dirname "$lock")"
        # Атомарный mkdir — POSIX гарантирует, что только один
        # каталог может быть создан.
        if mkdir "$lock" 2>/dev/null; then
          sleep 15
          rm -rf "$lock"
          exit 0
        fi
        exit 1
      '; \
      printf '%s\n' "$?" > "$WORK/c13d.rc.$i") &
  done
  wait
  for i in $(seq 1 64); do
    [ "$(cat "$WORK/c13d.rc.$i" 2>/dev/null)" = "0" ] && succ=$((succ+1))
  done
  rm -rf "$db" "$WORK/c13d.rc."* 2>/dev/null
  [ "$succ" -eq 1 ]
}

DIFF=0; DIFFSEEN=0
for n in c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13; do
  SEEN=$((SEEN+1))
  if "check_$n"; then CAUGHT=$((CAUGHT+1)); else printf '055-батарея: клетка %s НЕ поймала свой стаб\n' "$n" >&2; fi
  DIFFSEEN=$((DIFFSEEN+1))
  if "diff_$n"; then DIFF=$((DIFF+1)); else printf '055-батарея: диффпроба %s — стаб без ручки упал\n' "$n" >&2; fi
done
[ "$SEEN" -eq 13 ] || die_pack "счёт клеток ≠ 13: $SEEN (пустая/лишняя выборка — красная)"
[ "$CAUGHT" -eq 13 ] || { printf 'стаб-пак: поймано %s из %s\n' "$CAUGHT" "$SEEN" >&2; exit 1; }
[ "$DIFF" -eq 13 ] || { printf 'диффпроба: прошли %s из %s\n' "$DIFF" "$DIFFSEEN" >&2; exit 1; }
printf 'стаб-пак: 13/13 поймано, диффпроба 13/13 — различимость жива (Н-39)\n'

# ── г0: предмет отсутствует — FAIL-FAST ДО честной части (054-прецедент) ────
if ! grep -qF 'dev-harness-projects' "$WORKSHOP" 2>/dev/null; then
  printf 'ОТКАЗ: предмет отсутствует: %s/workshop (изоляция состояния по ProjectId — контракт 055)\n' "$ROOT" >&2
  exit 1
fi
if ! grep -qF 'packs' "$RESOLVER" 2>/dev/null; then
  printf 'ОТКАЗ: предмет отсутствует: %s (ключ packs — контракт 055)\n' "$RESOLVER" >&2
  exit 1
fi

# ── ЧЕСТНАЯ ЧАСТЬ (клетки h1..h13: живые бинарники; негативные — rc РОВНО 1 ─
# ── и полная фраза с фактическими root/pid/значением) ───────────────────────
HONEST=0; HSEEN=0
hcell() { local n="$1"; shift; HSEEN=$((HSEEN+1)); "$@" && HONEST=$((HONEST+1)) || printf '055-батарея: честная клетка %s красная\n' "$n" >&2; }

hbase="$WORK/hbase"
hlock="$hbase/dev-harness-projects/p1/sessions/$(root_hash8 "$R1").lock"
probe_run() { # $1=слой; probe живого workshop, rc наружу
  env XDG_STATE_HOME="$hbase" HARNESS_PROJECT_LAYER_ROOT="$1" bash "$WORKSHOP" --probe "$R1"
}
live_run() { # $1=база дампа; живой workshop со стаб-omp в PATH (субъект)
  env PATH="$SHIMDIR:$PATH" XDG_STATE_HOME="$hbase" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key METERING_PROXY_TOKEN=toy-token \
    SHIM_ENV="$1.env" SHIM_OUT="$1.pid" bash "$WORKSHOP" "$R1"
}
h1() { # И-2/И-3: probe rc 0, STATE-строка пер-проектная, без дев-зоны
  local out rc=0
  out="$(probe_run "$LAYER" 2>/dev/null)"; rc=$?
  [ "$rc" -eq 0 ] \
    && printf '%s' "$out" | grep -F 'STATE: ' | grep -Fq "dev-harness-projects/p1" \
    && ! printf '%s' "$out" | grep -F 'STATE: ' | grep -Fq 'dev-harness-sessions'
}
h2() { # И-2: два проекта развязаны; маркер A не виден в дереве B
  local oa ob
  oa="$(probe_run "$LAYER" 2>/dev/null | grep -F 'STATE: ' | sed 's/^STATE: //')"
  ob="$(env XDG_STATE_HOME="$hbase" HARNESS_PROJECT_LAYER_ROOT="$LAYER2" bash "$WORKSHOP" --probe "$R2" 2>/dev/null | grep -F 'STATE: ' | sed 's/^STATE: //')"
  [ "$oa" != "$ob" ] || return 1
  mkdir -p "$oa/home" 2>/dev/null
  printf 'marker-a' > "$oa/home/marker-055" 2>/dev/null
  ! find "$ob" -name 'marker-055' -print -quit 2>/dev/null | grep -q .
}
h3() { # И-4/И-6: живой лок → probe rc РОВНО 1 и ПОЛНАЯ W3 с фактическими root/pid
  mkdir -p "$hlock" 2>/dev/null
  sleep 30 & HOLDER=$!
  printf '%s\n' "$HOLDER" > "$hlock/pid"
  local o rc=0
  o="$(probe_run "$LAYER" 2>&1)"; rc=$?
  kill "$HOLDER" 2>/dev/null; wait "$HOLDER" 2>/dev/null
  [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq "$(w3_line "$(cd "$R1" && pwd -P)" "$HOLDER")"
}
h4() { # И-4: мёртвый PID в локе → замещение, probe rc 0
  sleep 30 & DEAD=$!; kill "$DEAD" 2>/dev/null; wait "$DEAD" 2>/dev/null
  mkdir -p "$hlock" 2>/dev/null
  printf '%s\n' "$DEAD" > "$hlock/pid"
  probe_run "$LAYER" >/dev/null 2>&1
}
h5() { # И-4 (битый лок): нечисловое содержимое → замещение, probe rc 0
  mkdir -p "$hlock" 2>/dev/null
  printf 'not-a-pid\n' > "$hlock/pid"
  probe_run "$LAYER" >/dev/null 2>&1
}
h6() { # И-6: чистый probe не оставляет лок
  rm -rf "$hlock" 2>/dev/null
  probe_run "$LAYER" >/dev/null 2>&1
  [ ! -d "$hlock" ]
}
h7() { # И-2/И-7: РЕАЛЬНЫЕ экспорты потомка (субъект-стаб-omp пишет факт env)
  local rc=0 P="$hbase/dev-harness-projects/p1"
  rm -rf "$hlock" 2>/dev/null
  live_run "$WORK/h7" >/dev/null 2>&1 || rc=$?
  [ "$rc" -eq 0 ] || return 1
  [ -s "$WORK/h7.env" ] || return 1
  grep -Fxq "HARNESS_SESSION_HOME=$P/home" "$WORK/h7.env" \
    && grep -Fxq "HOME=$P/home" "$WORK/h7.env" \
    && grep -Fxq "HARNESS_SCRATCH=$P/scratch" "$WORK/h7.env" \
    && grep -Fxq "XDG_STATE_HOME=$P/state" "$WORK/h7.env" \
    && grep -Fxq 'METERING_PROJECT=p1' "$WORK/h7.env" \
    && grep -Fxq 'METERING_ROLE=orchestrator' "$WORK/h7.env" \
    && ! grep -Eq '^(HOME|HARNESS_SESSION_HOME|HARNESS_SCRATCH|XDG_STATE_HOME)=.*dev-harness-sessions' "$WORK/h7.env"
}
h8() { # И-5/И-4: живой старт занимает лок (PID субъекта); вторая копия — rc 1 W3
  rm -rf "$hlock" 2>/dev/null
  env PATH="$SHIMDIR:$PATH" XDG_STATE_HOME="$hbase" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key METERING_PROXY_TOKEN=toy-token \
    SHIM_ENV="$WORK/h8.env" SHIM_OUT="$WORK/h8.pid" SHIM_SLEEP=20 \
    bash "$WORKSHOP" "$R1" >/dev/null 2>&1 &
  WPID=$!
  local i=0
  until [ -d "$hlock" ] || [ "$i" -ge 200 ]; do sleep 0.1; i=$((i+1)); done
  [ -d "$hlock" ] || { kill "$WPID" 2>/dev/null; wait "$WPID" 2>/dev/null; return 1; }
  local lpid shimpid o rc=0
  lpid="$(cat "$hlock/pid" 2>/dev/null)"
  kill -0 "$lpid" 2>/dev/null || { kill "$WPID" 2>/dev/null; wait "$WPID" 2>/dev/null; return 1; }
  shimpid="$(sed 's/^pid=//' "$WORK/h8.pid" 2>/dev/null)"
  [ -n "$shimpid" ] && [ "$lpid" = "$shimpid" ] || { kill "$WPID" 2>/dev/null; wait "$WPID" 2>/dev/null; return 1; }
  o="$(live_run "$WORK/h8b" 2>&1)"; rc=$?
  kill "$lpid" 2>/dev/null; wait "$lpid" 2>/dev/null
  rm -rf "$hlock" 2>/dev/null
  [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq "$(w3_line "$(cd "$R1" && pwd -P)" "$lpid")"
}
h9() { # И-1: projectId вне класса → probe rc РОВНО 1, ПОЛНАЯ W4, путей нет
  local hbase2="$WORK/hbase2" o rc=0
  layer_make "$WORK/layer-bad" 'Bad/Id'
  o="$(env XDG_STATE_HOME="$hbase2" HARNESS_PROJECT_LAYER_ROOT="$WORK/layer-bad" bash "$WORKSHOP" --probe "$R1" 2>&1)"; rc=$?
  [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq "$W4_LINE" && [ ! -d "$hbase2/dev-harness-projects" ]
}
h10() { # И-8/И-9: packs отсутствует → value [] origin project
  env HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$RESOLVER" --repo "$R7" 2>/dev/null | jq -e '.packs.value == [] and .packs.origin == "project"' >/dev/null 2>&1
}
h11() { # И-9: замещение единицей — packs репо-слоя → value ["core"] origin repo
  env HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$RESOLVER" --repo "$R11" 2>/dev/null | jq -e '.packs.value == ["core"] and .packs.origin == "repo"' >/dev/null 2>&1
}
h12() { # И-8: НЕ-список → rc РОВНО 1 и P6 с типом (формат барьеров 054)
  local o rc=0
  o="$(env HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$RESOLVER" --repo "$R8" 2>&1)"; rc=$?
  [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq 'profile ОТКАЗ: значение вне алфавита: packs: <string>'
}
h13() { # И-8: элемент вне класса → rc РОВНО 1 и P6 с ЭЛЕМЕНТОМ в причине
  local o rc=0
  o="$(env HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$RESOLVER" --repo "$R9" 2>&1)"; rc=$?
  [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq 'profile ОТКАЗ: значение вне алфавита: packs: Bad Pack!'
}
# ── фикс 055-к2 (адверсарий к1): честные клетки h14..h17 — к каждой находке по красной клетке
h14() { # И-8: пустой элемент packs → rc РОВНО 1 и P6 с маркером «пусто»
  local o rc=0
  o="$(env HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$RESOLVER" --repo "$R14" 2>&1)"; rc=$?
  [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq 'profile ОТКАЗ: значение вне алфавита: packs: пусто'
}
h15() { # И-8: newline-элемент packs → rc РОВНО 1 и P6 с маркером «пусто»
  local o rc=0
  o="$(env HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$RESOLVER" --repo "$R15" 2>&1)"; rc=$?
  [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq 'profile ОТКАЗ: значение вне алфавита: packs: пусто'
}
h16() { # М1: относительный PSTATE-base → rc РОВНО 1 и P6 с фактическим base
  local hbase3="$WORK/hbase-rel" o rc=0
  rm -rf "$hbase3" 2>/dev/null
  # Workshop запускается ИЗ project checkout: cd $R1 + XDG_STATE_HOME="relative-state".
  # Без фикса workshop тихо создал бы $R1/relative-state/... и завершился rc=0.
  # С фиксом — отказ rc=1 ДО mkdir (НЕ создаёт НИ ОДНОГО файла в checkout).
  o="$(cd "$R1" && env XDG_STATE_HOME="relative-state" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    bash "$WORKSHOP" --probe "$R1" 2>&1)"; rc=$?
  [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq 'workshop ОТКАЗ: PSTATE-base относительный: relative-state'
}
h17() { # М2: 16 параллельных live-стартов против атомарного mkdir → ровно 1 успех
  local tmpbase="$WORK/hbase-p" i succ=0 rc=0
  rm -rf "$tmpbase" "$WORK/h17.rc."* 2>/dev/null
  mkdir -p "$tmpbase"
  for i in $(seq 1 16); do
    (env PATH="$SHIMDIR:$PATH" XDG_STATE_HOME="$tmpbase" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
      ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key METERING_PROXY_TOKEN=toy-token \
      SHIM_ENV="$WORK/h17.e.$i" SHIM_OUT="$WORK/h17.p.$i" SHIM_SLEEP=15 \
      bash "$WORKSHOP" "$R1" >/dev/null 2>&1; \
      printf '%s\n' "$?" > "$WORK/h17.rc.$i") &
  done
  wait
  # Сначала читаем rc-файлы, потом прибираем.
  for i in $(seq 1 16); do
    if [ "$(cat "$WORK/h17.rc.$i" 2>/dev/null || echo 99)" = "0" ]; then
      succ=$((succ+1))
    fi
  done
  rm -rf "$tmpbase/dev-harness-projects/p1/sessions" 2>/dev/null
  rm -f "$WORK/h17.rc."* 2>/dev/null
  [ "$succ" -eq 1 ]
}

hcell h1 h1; hcell h2 h2; hcell h3 h3; hcell h4 h4; hcell h5 h5; hcell h6 h6
hcell h7 h7; hcell h8 h8; hcell h9 h9; hcell h10 h10; hcell h11 h11
hcell h12 h12; hcell h13 h13
hcell h14 h14; hcell h15 h15; hcell h16 h16; hcell h17 h17
[ "$HSEEN" -eq 17 ] || die_pack "счёт честных клеток ≠ 17: $HSEEN"
[ "$HONEST" -eq "$HSEEN" ] || { printf 'честная часть: %s из %s\n' "$HONEST" "$HSEEN" >&2; exit 1; }
printf 'честная часть: 17/17 зелёная; предъявлений: стабы 13/13 + дифф 13/13 + честные 17/17\n'
exit 0
