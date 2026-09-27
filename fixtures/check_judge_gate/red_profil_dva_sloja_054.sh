#!/usr/bin/env bash
# КРАСНОЕ 054 (контракт 054 — профиль два слоя + лаунчер режима проекта, В2+В3).
# До-заморозочный адрес — fixtures/check_judge_gate/ (union-зона architect,
# прецедент 045: red_gitw_obmen.sh жил здесь до заморозки); дом семьи
# fixtures/workshop_project/red_profil_dva_sloja.sh + раннер fixtures/_krasnye_054.sh —
# implementer переносит первым пост-заморозочным коммитом вместе с реализацией
# (прецедент 045: перенос батареи в fixtures/gitw/, 9c37233).
#
# Честная часть красна СЕЙЧАС ЕДИНСТВЕННОЙ причиной fail-fast г0
# «ОТКАЗ: предмет отсутствует: <корень>/scripts/profile_resolver.sh».
# Стаб-пак (исполняется ДО честной части) зелён И ДО реализации: каждый обманный
# стаб умирает на СВОЕЙ клетке именованно — различимость батареи не зависит от
# существования честного кода.
#
# ПРИВЯЗКА К КОДУ (Н-39: стаб умирает там, где его дефект НАБЛЮДАЕМ; список —
# код ниже, не prose контракта):
#   * МОЛЧАЛИВЫЙ-ENV      — молчаливый return при отсутствии .env проекта → умирает к12
#                           (P8 обязателен даже при экспортированном окружении);
#   * МЯГКИЙ-ПИН          — прежний skip при отсутствии пина («сверять не с   → умирает к13
#                           чем») вместо именованного отказа P9 с инструкцией;
#   * НЕПУСТОЕ-ПРОХОДИТ   — любое НЕПУСТОЕ denyCurrentBranch проходит         → умирает к7б
#                           (литерал 'refuse', updateInstead — тот же отказ W2
#                           со значением в причине; Н-143);
#   * ВЫВЕСКА-ПРАВИЛ      — промпт = тело роли + заголовок секции БЕЗ самих   → умирает к8(б)
#                           правил (контрмодель критика 054-Б3);
#   * ПОДМЕШИВАНИЕ-РЕПО   — AGENTS.md toy-репо подмешан в промпт сессии       → умирает к8(г)
#                           (область репо — omp, В3(а));
#   * ГЛУХОЙ-АЛФАВИТ      — неизвестный ключ молча игнорируется               → умирает к4
#                           (правило 7: P4 с точным путём ключа);
#   * ПИН-МОЛЧА           — расхождение пина слоя молча сливается            → умирает к6
#                           (P5 с обоими значениями);
#   * ПРОИСХОЖДЕНИЕ-ВРАСТЁТ — origin жёстко 'project' у переопределённых      → умирает к9
#                           репо настроек (origin обязан быть 'repo');
#   * САМ-СОЗДАЁТ         — bootstrap ГЕНЕРИРУЕТ harness.project.json за      → умирает к2
#                           проект (граница-7: отказ + файл не создан).
#
# Оракул — в памяти ДО вызова субъекта (правило 8): ожидания снимаются в
# переменные до запуска стаба/лаунчера; диск субъекта как истина не перечитывается.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="${1:-$(cd "$HERE/../.." && pwd -P)}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
[ -f "$ROOT/AGENTS.md" ] || { printf 'ОТКАЗ: нет AGENTS.md мастерской: %s\n' "$ROOT" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { printf 'ОТКАЗ: нет git\n' >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { printf 'ОТКАЗ: нет jq\n' >&2; exit 1; }

die_pack() { printf '054-батарея ОТКАЗ: %s\n' "$*" >&2; exit 1; }

HDR='## Правила, каждое из которых уже стоило времени'
TOY_HDR='## Правила проекта Odelix-toy'

# ── строители toy-мира ────────────────────────────────────────────────────────
layer_make() { # $1=каталог слоя
  mkdir -p "$1/registry"
  printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"rust","commands":{"test":"cargo test"},"git":{"canonicalRemote":"git@host:p1.git"},"barriers":{"mandatory":["check_zones"],"optional":[]}}}\n' > "$1/registry/harness-project.json"
}
repo_make() { # $1=каталог репо, $2=language, $3=с-пином(1/0), $4=с-.env(1/0), $5=пин-версия
  mkdir -p "$1/config"
  git -C "$1" init -q
  git -C "$1" config receive.denyCurrentBranch refuse
  printf '{"schemaVersion":1,"repoId":"r1","language":"%s","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"ci":{"workflow":".github/workflows/ci.yml"},"git":{"canonicalRemote":"git@host:r1.git"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' "$2" > "$1/harness.project.json"
  [ "$3" = 1 ] && printf '{"version":"%s"}\n' "$5" > "$1/config/harness_pin.json"
  [ "$4" = 1 ] && printf 'METERING_PROXY_URL=http://toy.invalid:1\n' > "$1/.env"
  printf '# Toy project AGENTS\n\n%s\n\nПравило toy-репо: не подмешиваться в системный промпт.\n' "$TOY_HDR" > "$1/AGENTS.md"
}
section_of() { # $1=AGENTS.md → stdout: секция правил (заголовок+тело, до следующего '## ')
  awk -v h="$HDR" '$0 == h {f = 1; print; next} f && /^## / {exit} f {print}' "$1"
}

# ── обманные стабы (генератор: один скелет, ручки обмана — env) ──────────────
stub_workshop() { # $1=путь-файл
  cat > "$1" <<'STUB'
#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ лаунчера 054 (контракт 054): выглядит как режим проекта,
# обманывает ровно одной ручкой (STUB_*). Реализацией НЕ является.
set -uo pipefail
repo="${2:-}"
prompt="$TMP_STUB_HOME/prompt.md"
mkdir -p "$TMP_STUB_HOME"
v="$(git -C "$repo" config --get receive.denyCurrentBranch 2>/dev/null || true)"
if [ -n "${STUB_DENY_NONEMPTY:-}" ]; then
  [ -n "$v" ] || { printf "workshop ОТКАЗ: receive.denyCurrentBranch='' в %s, ожидается 'refuse'. Исправление: git -C %s config receive.denyCurrentBranch refuse\n" "$repo" "$repo" >&2; exit 1; }
else
  [ "$v" = "refuse" ] || { printf "workshop ОТКАЗ: receive.denyCurrentBranch='%s' в %s, ожидается 'refuse'. Исправление: git -C %s config receive.denyCurrentBranch refuse\n" "$v" "$repo" "$repo" >&2; exit 1; }
fi
[ -z "${STUB_SKIP_ENV:-}" ] && { [ -f "$repo/.env" ] || { printf 'profile ОТКАЗ: нет .env проекта: %s/.env. Инструкция: создайте .env в корне репо — METERING_PROXY_URL=<адрес прокси учёта проекта>\n' "$repo" >&2; exit 1; }; }
[ -z "${STUB_SKIP_PIN:-}" ] && { [ -f "$repo/config/harness_pin.json" ] || { printf 'profile ОТКАЗ: нет пина версии omp: %s/config/harness_pin.json. Инструкция: создайте config/harness_pin.json в корне репо — {"version": "<версия omp>"}\n' "$repo" >&2; exit 1; }; }
[ -f "$repo/harness.project.json" ] || { [ -n "${STUB_AUTOCREATE:-}" ] || { printf 'profile ОТКАЗ: нет harness.project.json: %s/harness.project.json. Инструкция: создайте harness.project.json в корне репо — состав ключей: scripts/profile_resolver.sh\n' "$repo" >&2; exit 1; }
  printf '{"schemaVersion":1,"repoId":"stub","language":"typescript"}\n' > "$repo/harness.project.json"; }
node "$HARNESS_ROOT/scripts/gen-harness.ts" --prompt orchestrator > "$prompt" 2>/dev/null || { printf 'ОТКАЗ: gen-harness --prompt\n' >&2; exit 1; }
printf '\n' >> "$prompt"
if [ -n "${STUB_VIVISKA:-}" ]; then
  printf '%s\n' "$RULES_HDR" >> "$prompt"
else
  awk -v h="$RULES_HDR" '$0 == h {f = 1; print; next} f && /^## / {exit} f {print}' "$HARNESS_ROOT/AGENTS.md" >> "$prompt"
fi
[ -n "${STUB_PODMESHENIE:-}" ] && cat "$repo/AGENTS.md" >> "$prompt"
printf 'workshop PROBE OK: %s\n' "$repo"
printf 'PROMPT: %s\n' "$prompt"
exit 0
STUB
  chmod +x "$1"
}
stub_resolver() { # $1=путь-файл — обманный стаб резолвера (обман — ручкой STUB_*)
  cat > "$1" <<'STUB'
#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ резолвера 054: без ручек ведёт себя честно на клетках к4/к6/к9,
# обманывает ровно одной ручкой (STUB_*). Реализацией НЕ является.
set -uo pipefail
repo="${3:-${2:-}}"
[ -n "$repo" ] || { printf 'profile ОТКАЗ: --repo пуст\n' >&2; exit 1; }
[ -f "$repo/harness.project.json" ] || { printf 'profile ОТКАЗ: нет harness.project.json: %s/harness.project.json. Инструкция: создайте harness.project.json в корне репо — состав ключей: scripts/profile_resolver.sh\n' "$repo" >&2; exit 1; }
[ -n "${HARNESS_PROJECT_LAYER_ROOT:-}" ] || { printf 'profile ОТКАЗ: корень слоя проекта не задан/недоступен. Инструкция: export HARNESS_PROJECT_LAYER_ROOT=<корень клона слоя проекта (odelix-stack)>\n' >&2; exit 1; }
[ -f "${HARNESS_PROJECT_LAYER_ROOT%/}/registry/harness-project.json" ] || { printf 'profile ОТКАЗ: нет файла слоя проекта: %s/registry/harness-project.json\n' "${HARNESS_PROJECT_LAYER_ROOT%/}" >&2; exit 1; }
unknown="$(jq -r '.workflowPaths // {} | keys[] | select(. != "contracts" and . != "verdicts" and . != "registry" and . != "fixtures")' "$repo/harness.project.json" | head -n 1)"
if [ -n "$unknown" ]; then
  [ -n "${STUB_IGNORE_UNKNOWN:-}" ] || { printf 'profile ОТКАЗ: неизвестный ключ репо-слой: workflowPaths.%s\n' "$unknown" >&2; exit 1; }
fi
if [ -z "${STUB_IGNORE_PIN:-}" ]; then
  rp="$(jq -r '.projectLayer.version' "$repo/harness.project.json")"
  pv="$(jq -r '.version' "${HARNESS_PROJECT_LAYER_ROOT%/}/registry/harness-project.json")"
  [ "$rp" = "$pv" ] || { printf "profile ОТКАЗ: пин слоя проекта расходится: репо пинит '%s', слой несёт '%s'\n" "$rp" "$pv" >&2; exit 1; }
fi
lang="$(jq -r '.language // empty' "$repo/harness.project.json")"
[ -n "$lang" ] || lang="$(jq -r '.defaults.language // empty' "${HARNESS_PROJECT_LAYER_ROOT%/}/registry/harness-project.json")"
if [ -n "${STUB_ORIGIN_PROJECT:-}" ]; then o='project'; else o='repo'; fi
jq -cn --arg l "$lang" --arg o "$o" '{language: {value: $l, origin: $o}, projectId: {value: "p1", origin: "project"}, repoId: {value: "r1", origin: "repo"}}'
exit 0
STUB
  chmod +x "$1"
}

# ── клетки-предикаты (0 = испытуемый проходит клетку; 1 = пойман) ─────────────
cell_k2() { # $1=workshop: нет профиля → rc 1 P1, файл НЕ создан (САМ-СОЗДАЁТ)
  local r="$WORK/k2-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 1 1 v10; rm -f "$r/harness.project.json"
  out="$(bash "$1" --probe "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'profile ОТКАЗ: нет harness.project.json:' <<<"$out" && [ ! -f "$r/harness.project.json" ]; } && return 0
  return 1
}
cell_k4() { # $1=resolver: неизвестный ключ workflowPaths.contrete → rc 1 P4 (ГЛУХОЙ-АЛФАВИТ)
  local r="$WORK/k4-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 1 1 v10
  jq '.workflowPaths.contrete = "x"' "$r/harness.project.json" > "$r/harness.project.json.new" && mv "$r/harness.project.json.new" "$r/harness.project.json"
  out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$1" --repo "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'profile ОТКАЗ: неизвестный ключ' <<<"$out" && grep -qF 'workflowPaths.contrete' <<<"$out"; } && return 0
  return 1
}
cell_k6() { # $1=resolver: пин v9 против слоя v10 → rc 1 P5, названы оба (ПИН-МОЛЧА)
  local r="$WORK/k6-repo" out rc
  rm -rf "$r"; repo_make "$r" rust 1 1 v10
  jq '.projectLayer.version = "v9"' "$r/harness.project.json" > "$r/harness.project.json.tmp" && mv "$r/harness.project.json.tmp" "$r/harness.project.json"
  out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$1" --repo "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'пин слоя проекта расходится' <<<"$out" && grep -qF "v9" <<<"$out" && grep -qF "v10" <<<"$out"; } && return 0
  return 1
}
cell_k7b() { # $1=workshop: явное updateInstead → rc 1 W2 со значением (НЕПУСТОЕ-ПРОХОДИТ)
  local r="$WORK/k7b-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 1 1 v10
  git -C "$r" config receive.denyCurrentBranch updateInstead
  out="$(bash "$1" --probe "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "receive.denyCurrentBranch='updateInstead'" <<<"$out" && grep -qF 'ожидается' <<<"$out"; } && return 0
  return 1
}
cell_k8() { # $1=workshop: тело роли ЗАТЕМ правила ЦЕЛИКОМ (побайтово), без AGENTS репо
  local r="$WORK/k8-repo" out rc pmode first_role_line hdr_line
  rm -rf "$r"; repo_make "$r" typescript 1 1 v10
  # оракул — в память ДО вызова (правило 8)
  section_of "$ROOT/AGENTS.md" > "$WORK/k8-expected.section"
  first_role_line="$(node "$ROOT/scripts/gen-harness.ts" --prompt orchestrator 2>/dev/null | sed -n '/./{p;q}')"
  [ -s "$WORK/k8-expected.section" ] && grep -qFx "$HDR" "$WORK/k8-expected.section" || return 1
  [ -n "$first_role_line" ] || return 1
  out="$(bash "$1" --probe "$r" 2>&1)"; rc=$?
  pmode="$(grep -F 'PROMPT: ' <<<"$out" | sed 's/^PROMPT: //')"
  { [ "$rc" -eq 0 ] && [ -n "$pmode" ] && [ -f "$pmode" ]; } || return 1
  grep -qFx "$HDR" "$pmode" || return 1                       # (а) заголовок самостоятельной строкой
  awk -v h="$HDR" '$0 == h {f = 1; next} f && /^## / {exit} f {print}' "$pmode" > "$WORK/k8-actual.body"
  awk 'NR > 1' "$WORK/k8-expected.section" > "$WORK/k8-expected.body"
  cmp -s "$WORK/k8-actual.body" "$WORK/k8-expected.body" || return 1   # (б) тело правил ПОБАЙТОВО
  hdr_line="$(grep -nFx "$HDR" "$pmode" | head -1 | cut -d: -f1)"
  [ "$(grep -nF -- "$first_role_line" "$pmode" | head -1 | cut -d: -f1)" -lt "$hdr_line" ] || return 1  # (в) роль раньше правил
  grep -qFx "$TOY_HDR" "$pmode" && return 1                    # (г) заголовков AGENTS.md репо НЕТ
  return 0
}
cell_k9() { # $1=resolver: override языка → language.origin=repo, projectId.origin=project
  local r="$WORK/k9-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 1 1 v10
  out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$1" --repo "$r" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] || return 1
  [ "$(jq -r '.language.value' <<<"$out")" = "typescript" ] || return 1
  [ "$(jq -r '.language.origin' <<<"$out")" = "repo" ] || return 1
  [ "$(jq -r '.projectId.origin' <<<"$out")" = "project" ] || return 1
  return 0
}
cell_k12() { # $1=workshop: нет .env (окружение экспортировано!) → rc 1 P8 (МОЛЧАЛИВЫЙ-ENV)
  local r="$WORK/k12-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 1 0 v10
  out="$(METERING_PROXY_URL=http://exported.invalid:1 bash "$1" --probe "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'нет .env проекта:' <<<"$out" && grep -qF 'Инструкция: создайте .env в корне репо' <<<"$out"; } && return 0
  return 1
}
cell_k13() { # $1=workshop: нет config/harness_pin.json → rc 1 P9 с инструкцией (МЯГКИЙ-ПИН)
  local r="$WORK/k13-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 0 1 v10; rm -f "$r/config/harness_pin.json"
  out="$(bash "$1" --probe "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'нет пина версии omp:' <<<"$out" && grep -qF '{"version": "<версия omp>"}' <<<"$out"; } && return 0
  return 1
}

# ── СТАБ-ПАК (ДО честной части; зелён и до реализации) ───────────────────────
run_stub_pack() {
  layer_make "$WORK/layer"
  mkdir -p "$WORK/stub/scripts"
  local caught=0 total=0
  declare -a NAMES=() CELLS=() KNOBS=()
  NAMES+=(МОЛЧАЛИВЫЙ-ENV);    CELLS+=(k12); KNOBS+=("STUB_SKIP_ENV=1")
  NAMES+=(МЯГКИЙ-ПИН);        CELLS+=(k13); KNOBS+=("STUB_SKIP_PIN=1")
  NAMES+=(НЕПУСТОЕ-ПРОХОДИТ); CELLS+=(k7b); KNOBS+=("STUB_DENY_NONEMPTY=1")
  NAMES+=(ВЫВЕСКА-ПРАВИЛ);    CELLS+=(k8);  KNOBS+=("STUB_VIVISKA=1")
  NAMES+=(ПОДМЕШИВАНИЕ-РЕПО); CELLS+=(k8);  KNOBS+=("STUB_PODMESHENIE=1")
  NAMES+=(ГЛУХОЙ-АЛФАВИТ);    CELLS+=(k4);  KNOBS+=("STUB_IGNORE_UNKNOWN=1")
  NAMES+=(ПИН-МОЛЧА);         CELLS+=(k6);  KNOBS+=("STUB_IGNORE_PIN=1")
  NAMES+=(ПРОИСХОЖДЕНИЕ-ВРАСТЁТ); CELLS+=(k9); KNOBS+=("STUB_ORIGIN_PROJECT=1")
  NAMES+=(САМ-СОЗДАЁТ);       CELLS+=(k2);  KNOBS+=("STUB_AUTOCREATE=1")
  [ "${#NAMES[@]}" -gt 0 ] || die_pack 'пустая выборка стаб-пака — не проверено ничего'
  # среда для стабов (наследуется вызываемым стаб-скриптом)
  export HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" RULES_HDR="$HDR" HARNESS_ROOT="$ROOT" TMP_STUB_HOME="$WORK/stub-home"
  for i in "${!NAMES[@]}"; do
    total=$((total + 1))
    local cell="${CELLS[$i]}" kn="${KNOBS[$i]}" subj=
    if [ "$cell" = k4 ] || [ "$cell" = k6 ] || [ "$cell" = k9 ]; then
      stub_resolver "$WORK/stub/scripts/profile_resolver.sh"
      subj="$WORK/stub/scripts/profile_resolver.sh"
    else
      stub_workshop "$WORK/stub/workshop"
      subj="$WORK/stub/workshop"
    fi
    # ручка обмана — в среду стаба; клетка-предикат идёт в ТОМ ЖЕ шелле (функции
    # определены выше): стаб пойман ⇔ клетка НЕ пропустила его (rc клетки ≠ 0)
    export "$kn"
    if "cell_$cell" "$subj"; then
      die_pack "СТАБ ВЫЖИЛ: ${NAMES[$i]} прошёл клетку $cell — различимость не доказана"
    fi
    unset "${kn%%=*}"
    caught=$((caught + 1))
    printf 'стаб пойман: %s — клетка %s\n' "${NAMES[$i]}" "$cell"
  done
  printf 'стаб-пак: просмотрено %s, поймано %s (пустая выборка была бы красной)\n' "$total" "$caught" >&2
  [ "$caught" -eq "$total" ]
}

# ── ЧЕСТНАЯ ЧАСТЬ (красна сейчас г0; зелёна после реализации) ────────────────
run_honest() {
  # г0 fail-fast: предмет отсутствует — ЕДИНСТВЕННАЯ красная причина сейчас
  if [ ! -f "$ROOT/scripts/profile_resolver.sh" ]; then
    printf 'ОТКАЗ: предмет отсутствует: %s/scripts/profile_resolver.sh\n' "$ROOT" >&2
    exit 1
  fi
  # к1 (пост-реализация): probe на двух стеках → rc 0 W1 PROMPT (граница-3)
  local lang r out rc pmode
  for lang in rust typescript; do
    r="$WORK/honest-$lang"
    repo_make "$r" "$lang" 1 1 v10
    out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$ROOT/workshop" --probe "$r" 2>&1)"; rc=$?
    pmode="$(grep -F 'PROMPT: ' <<<"$out" | sed 's/^PROMPT: //')"
    { [ "$rc" -eq 0 ] && grep -qF "workshop PROBE OK: $r" <<<"$out" && [ -n "$pmode" ] && [ -f "$pmode" ]; } \
      || die_pack "к1: probe на $lang дал rc=$rc: $(printf '%s' "$out" | tail -n 2 | tr '\n' ' ')"
    rm -rf "$r"
  done
}

run_stub_pack
run_honest
printf '054-батарея зелёная: стаб-пак на своих клетках + честные клетки г0/к1\n' >&2
exit 0
