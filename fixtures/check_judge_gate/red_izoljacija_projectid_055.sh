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
#   2. ЧЕСТНАЯ ЧАСТЬ (клетки c1h..c10h) — красная ДО реализации
#      (г0: предмет отсутствует), зелёная ПОСЛЕ.
#
# Прогон: bash red_izoljacija_projectid_055.sh [корень worktree]
#   rc 0 — стаб-пак пойман (9/9) И честная часть зелёная.
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

W3='workshop ОТКАЗ: на корне'

# ── строители toy-мира (054-прецедент; слой+репо, 4.3, .env, пин) ───────────
layer_make() { # $1=корень слоя $2=projectId
  mkdir -p "$1/registry"
  printf '{"schemaVersion":1,"version":"v10","projectId":"%s","workspaceId":"w1","defaults":{"language":"rust"}}' "$2" > "$1/registry/harness-project.json"
}
repo_make() { # $1=корень репо $2=repoId $3=packs-jq-значение ("-" = ключа нет)
  local r="$1"
  mkdir -p "$r/config"
  git -C "$r" init -q
  git -C "$r" config receive.denyCurrentBranch refuse
  if [ "${3:-}" = "-" ]; then
    printf '{"schemaVersion":1,"repoId":"%s","language":"rust","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}' "$2" > "$r/harness.project.json"
  else
    printf '{"schemaVersion":1,"repoId":"%s","language":"rust","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"},"packs":%s}' "$2" "${3:-[]}" > "$r/harness.project.json"
  fi
  printf '{"version":"v10"}\n' > "$r/config/harness_pin.json"
  printf 'METERING_PROXY_URL=http://toy.invalid:1\n' > "$r/.env"
}
root_hash8() { printf '%s' "$(cd "$1" && pwd -P)" | sha256sum | cut -c1-8; }

# ── ОБМАННЫЙ СТАБ лаунчера 055: выглядит как режим проекта; обманывает───────
# ровно одной ручкой STUB_*; без ручек честен на своих клетках (c1..c6).
cat > "$WORK/stub-workshop" <<'STUB'
#!/usr/bin/env bash
set -uo pipefail
repo="${2:-}"
pid="$(jq -r '.projectId' "$HARNESS_PROJECT_LAYER_ROOT/registry/harness-project.json")"
base="${TMP_BASE_055:-$(mktemp -d)}"
# W4: projectId вне класса пути — именованный отказ (И-1); ручка STUB_PID_CLASS_BAD
# подменяет проверку молчаливой нормализацией.
if printf '%s' "$pid" | grep -Eqv '^[a-z0-9][a-z0-9_-]*$'; then
  if [ -z "${STUB_PID_CLASS_BAD:-}" ]; then
    printf "workshop ОТКАЗ: projectId вне класса пути: %s (класс ^[a-z0-9][a-z0-9_-]*$) — правь слой проекта\n" "$pid" >&2
    exit 1
  fi
  pid="normalized"
fi
# s1: state-корень от hash8 МАСТЕРСКОЙ (дев-зона); s2: projectId проигнорирован.
if [ -n "${STUB_IGNORE_PROJECTID:-}" ]; then
  pstate="$base/dev-harness-sessions/$(printf '%s' "$base" | sha256sum | cut -c1-8)"
elif [ -n "${STUB_SHARED_STATE:-}" ]; then
  pstate="$base/dev-harness-projects/shared"
else
  pstate="$base/dev-harness-projects/$pid"
fi
lock="$pstate/sessions/$(printf '%s' "$(cd "$repo" && pwd -P)" | sha256sum | cut -c1-8).lock"
mkdir -p "$pstate/sessions" "$pstate/home"
# s3: живой лок не судится; s4: мёртвый лок не замещается.
if [ -f "$lock" ]; then
  lpid="$(cat "$lock" 2>/dev/null || true)"
  alive=0; [ -n "$lpid" ] && kill -0 "$lpid" 2>/dev/null && alive=1
  if [ "$alive" = 1 ] && [ -z "${STUB_NO_LOCK:-}" ]; then
    printf 'workshop ОТКАЗ: на корне %s уже идёт сессия (pid %s). Вторая сессия на том же корне запрещена (Н-108): заверши её или работай в другом клоне\n' "$(cd "$repo" && pwd -P)" "$lpid" >&2
    exit 1
  fi
  if [ "$alive" = 0 ] && [ -n "${STUB_STALE_REFUSAL:-}" ]; then
    printf 'workshop ОТКАЗ: на корне %s уже идёт сессия (pid %s). Вторая сессия на том же корне запрещена (Н-108): заверши её или работай в другом клоне\n' "$(cd "$repo" && pwd -P)" "$lpid" >&2
    exit 1
  fi
fi
printf 'workshop PROBE OK: %s\n' "$repo"
printf 'PROMPT: %s/session-prompt-orchestrator.md\n' "$pstate/home"
printf 'STATE: %s\n' "$pstate"
# s6: метеринг-строка не печатается.
if [ -z "${STUB_NO_METERING_ENV:-}" ]; then
  printf 'METERING: project=%s role=%s\n' "$pid" "orchestrator"
fi
# s5: probe занимает лок (контрмодель — блокирует следующий живой старт).
[ -n "${STUB_PROBE_HOLDS_LOCK:-}" ] && printf '%s\n' "$$" > "$lock"
exit 0
STUB
chmod +x "$WORK/stub-workshop"

# ── ОБМАННЫЙ СТАБ резолвера 055: packs-семантика; обман одной ручкой ────────
cat > "$WORK/stub-resolver" <<'STUB'
#!/usr/bin/env bash
set -uo pipefail
repo=""
while [ $# -gt 0 ]; do case "$1" in --repo) repo="${2:-}"; shift ;; *) repo="$1" ;; esac; shift; done
[ -f "$repo/harness.project.json" ] || { printf 'profile ОТКАЗ: нет harness.project.json: %s/harness.project.json\n' "$repo" >&2; exit 1; }
ptype="$(jq -r '.packs | type' "$repo/harness.project.json" 2>/dev/null || echo missing)"
if [ "$ptype" = "string" ] || [ "$ptype" = "object" ] || [ "$ptype" = "number" ]; then
  if [ -z "${STUB_PACKS_NONLIST_OK:-}" ]; then
    printf 'profile ОТКАЗ: значение вне алфавита: packs: <%s>\n' "$(jq -r '.packs' "$repo/harness.project.json")" >&2
    exit 1
  fi
fi
if [ "$ptype" = "array" ]; then
  bad="$(jq -r '.packs[] | select(test("^[a-z0-9][a-z0-9_-]*$") | not)' "$repo/harness.project.json" 2>/dev/null | head -n 1)"
  if [ -n "$bad" ] && [ -z "${STUB_PACKS_ELEM_OK:-}" ]; then
    printf 'profile ОТКАЗ: значение вне алфавита: packs: %s\n' "$bad" >&2
    exit 1
  fi
fi
out="$(jq -c '. + {packs: (.packs // [])}' "$repo/harness.project.json")"
if [ -n "${STUB_PACKS_MISSING_OK:-}" ]; then
  out="$(printf '%s' "$out" | jq -c 'del(.packs)')"
fi
printf '%s\n' "$out"
exit 0
STUB
chmod +x "$WORK/stub-resolver"

# ── стаб-пак: клетки c1..c9, каждая ловит СВОЙ стаб; счёт напечатан ─────────
CAUGHT=0; SEEN=0
LAYER="$WORK/layer-p1"; layer_make "$LAYER" p1; R1="$WORK/repo-p1"; repo_make "$R1" r1
LAYER2="$WORK/layer-p2"; layer_make "$LAYER2" p2; R2="$WORK/repo-p2"; repo_make "$R2" r2

check_c1() { # s1: дев-зона вместо пер-проектного state
  local out
  out="$(env TMP_BASE_055="$WORK/base" STUB_IGNORE_PROJECTID=1 HARNESS_PROJECT_LAYER_ROOT="$LAYER" "$WORK/stub-workshop" --probe "$R1" 2>/dev/null)"
  printf '%s' "$out" | grep -F 'STATE: ' | grep -Fq 'dev-harness-projects/p1' && return 1
  printf '%s' "$out" | grep -Fq 'dev-harness-sessions'
}
diff_c1() {
  local out
  out="$(env TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" "$WORK/stub-workshop" --probe "$R1" 2>/dev/null)"
  printf '%s' "$out" | grep -F 'STATE: ' | grep -Fq 'dev-harness-projects/p1'
}
check_c2() { # s2: общий state у двух проектов
  local oa ob
  oa="$(env TMP_BASE_055="$WORK/base" STUB_SHARED_STATE=1 HARNESS_PROJECT_LAYER_ROOT="$LAYER" "$WORK/stub-workshop" --probe "$R1" 2>/dev/null | grep -F 'STATE: ')"
  ob="$(env TMP_BASE_055="$WORK/base" STUB_SHARED_STATE=1 HARNESS_PROJECT_LAYER_ROOT="$LAYER2" "$WORK/stub-workshop" --probe "$R2" 2>/dev/null | grep -F 'STATE: ')"
  [ "$oa" = "$ob" ]
}
diff_c2() {
  local oa ob
  oa="$(env TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" "$WORK/stub-workshop" --probe "$R1" 2>/dev/null | grep -F 'STATE: ')"
  ob="$(env TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER2" "$WORK/stub-workshop" --probe "$R2" 2>/dev/null | grep -F 'STATE: ')"
  [ "$oa" != "$ob" ]
}
LOCK1="$WORK/base/dev-harness-projects/p1/sessions/$(root_hash8 "$R1").lock"
check_c3() { # s3: живой лок игнорируется
  mkdir -p "$WORK/base/dev-harness-projects/p1/sessions"
  sleep 30 & HOLDER=$!
  printf '%s\n' "$HOLDER" > "$LOCK1"
  local rc_stub=0 rc_honest=0
  env TMP_BASE_055="$WORK/base" STUB_NO_LOCK=1 HARNESS_PROJECT_LAYER_ROOT="$LAYER" "$WORK/stub-workshop" --probe "$R1" >/dev/null 2>&1 || rc_stub=$?
  env TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" "$WORK/stub-workshop" --probe "$R1" >/dev/null 2>&1 || rc_honest=$?
  kill "$HOLDER" 2>/dev/null; wait "$HOLDER" 2>/dev/null
  [ "$rc_stub" -eq 0 ] && [ "$rc_honest" -ne 0 ]
}
diff_c3() {
  rm -f "$LOCK1"
  env TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" "$WORK/stub-workshop" --probe "$R1" >/dev/null 2>&1
}
check_c4() { # s4: мёртвый лок не замещается
  mkdir -p "$WORK/base/dev-harness-projects/p1/sessions"
  rm -f "$LOCK1"
  sleep 30 & DEAD=$!; kill "$DEAD" 2>/dev/null; wait "$DEAD" 2>/dev/null
  printf '%s\n' "$DEAD" > "$LOCK1"
  local rc_stub=0 rc_honest=0
  env TMP_BASE_055="$WORK/base" STUB_STALE_REFUSAL=1 HARNESS_PROJECT_LAYER_ROOT="$LAYER" "$WORK/stub-workshop" --probe "$R1" >/dev/null 2>&1 || rc_stub=$?
  env TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" "$WORK/stub-workshop" --probe "$R1" >/dev/null 2>&1 || rc_honest=$?
  [ "$rc_stub" -ne 0 ] && [ "$rc_honest" -eq 0 ]
}
diff_c4() {
  rm -f "$LOCK1"
  env TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" "$WORK/stub-workshop" --probe "$R1" >/dev/null 2>&1
}
check_c5() { # s5: probe занимает лок
  mkdir -p "$WORK/base/dev-harness-projects/p1/sessions"
  rm -f "$LOCK1"
  env TMP_BASE_055="$WORK/base" STUB_PROBE_HOLDS_LOCK=1 HARNESS_PROJECT_LAYER_ROOT="$LAYER" "$WORK/stub-workshop" --probe "$R1" >/dev/null 2>&1
  [ -f "$LOCK1" ]
}
diff_c5() {
  rm -f "$LOCK1"
  env TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" "$WORK/stub-workshop" --probe "$R1" >/dev/null 2>&1
  [ ! -f "$LOCK1" ]
}
check_c6() { # s6: метеринг-строка отсутствует
  ! env TMP_BASE_055="$WORK/base" STUB_NO_METERING_ENV=1 HARNESS_PROJECT_LAYER_ROOT="$LAYER" "$WORK/stub-workshop" --probe "$R1" 2>/dev/null | grep -Fq 'METERING: project=p1 role=orchestrator'
}
diff_c6() {
  env TMP_BASE_055="$WORK/base" HARNESS_PROJECT_LAYER_ROOT="$LAYER" "$WORK/stub-workshop" --probe "$R1" 2>/dev/null | grep -Fq 'METERING: project=p1 role=orchestrator'
}
R7="$WORK/repo-c7"; repo_make "$R7" r7 -
R8="$WORK/repo-c8"; repo_make "$R8" r8 '"core"'
R9="$WORK/repo-c9"; repo_make "$R9" r9 '["Bad Pack!"]'
check_c7() { # s7: packs отсутствует → ключ пропущен из вывода
  ! env STUB_PACKS_MISSING_OK=1 "$WORK/stub-resolver" --repo "$R7" 2>/dev/null | jq -e '.packs == []' >/dev/null 2>&1
}
diff_c7() { env "$WORK/stub-resolver" --repo "$R7" 2>/dev/null | jq -e '.packs == []' >/dev/null 2>&1; }
check_c8() { # s8: НЕ-список packs принят
  local rc_stub=0
  env STUB_PACKS_NONLIST_OK=1 "$WORK/stub-resolver" --repo "$R8" >/dev/null 2>&1 || rc_stub=$?
  [ "$rc_stub" -eq 0 ]
}
diff_c8() { local o; o="$(env "$WORK/stub-resolver" --repo "$R8" 2>&1)"; printf '%s' "$o" | grep -Fq 'profile ОТКАЗ: значение вне алфавита: packs:'; }
check_c9() { # s9: элемент вне класса принят
  local rc_stub=0
  env STUB_PACKS_ELEM_OK=1 "$WORK/stub-resolver" --repo "$R9" >/dev/null 2>&1 || rc_stub=$?
  [ "$rc_stub" -eq 0 ]
}
diff_c9() { local o; o="$(env "$WORK/stub-resolver" --repo "$R9" 2>&1)"; printf '%s' "$o" | grep -Fq 'profile ОТКАЗ: значение вне алфавита: packs: Bad Pack!'; }

DIFF=0; DIFFSEEN=0
for n in c1 c2 c3 c4 c5 c6 c7 c8 c9; do
  SEEN=$((SEEN+1))
  if "check_$n"; then CAUGHT=$((CAUGHT+1)); else printf '055-батарея: клетка %s НЕ поймала свой стаб\n' "$n" >&2; fi
  DIFFSEEN=$((DIFFSEEN+1))
  if "diff_$n"; then DIFF=$((DIFF+1)); else printf '055-батарея: диффпроба %s — стаб без ручки упал\n' "$n" >&2; fi
done
[ "$SEEN" -eq 9 ] || die_pack "счёт клеток ≠ 9: $SEEN (пустая/лишняя выборка — красная)"
[ "$CAUGHT" -eq 9 ] || { printf 'стаб-пак: поймано %s из %s\n' "$CAUGHT" "$SEEN" >&2; exit 1; }
[ "$DIFF" -eq 9 ] || { printf 'диффпроба: прошли %s из %s\n' "$DIFF" "$DIFFSEEN" >&2; exit 1; }
printf 'стаб-пак: 9/9 поймано, диффпроба 9/9 — различимость жива (Н-39)\n'

# ── г0: предмет отсутствует — FAIL-FAST ДО честной части (054-прецедент) ────
if ! grep -qF 'dev-harness-projects' "$WORKSHOP" 2>/dev/null; then
  printf 'ОТКАЗ: предмет отсутствует: %s/workshop (изоляция состояния по ProjectId — контракт 055)\n' "$ROOT" >&2
  exit 1
fi
if ! grep -qF 'packs' "$RESOLVER" 2>/dev/null; then
  printf 'ОТКАЗ: предмет отсутствует: %s (ключ packs — контракт 055)\n' "$RESOLVER" >&2
  exit 1
fi

# ── ЧЕСТНАЯ ЧАСТЬ (клетки c1h..c10h: те же предикаты на живых бинарниках) ────
HONEST=0; HSEEN=0
hcell() { local n="$1"; shift; HSEEN=$((HSEEN+1)); "$@" && HONEST=$((HONEST+1)) || printf '055-батарея: честная клетка %s красная\n' "$n" >&2; }

HLOCK="$WORK/hbase/dev-harness-projects/p1/sessions/$(root_hash8 "$R1").lock"
c1h() { # И-2/И-3: STATE-строка пер-проектная, без дев-зоны мастерской
  local out
  out="$(env XDG_STATE_HOME="$WORK/hbase" HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$WORKSHOP" --probe "$R1" 2>/dev/null)"
  printf '%s' "$out" | grep -F 'STATE: ' | grep -Fq 'dev-harness-projects/p1'
}
c2h() { # И-2: два проекта развязаны; маркер A не виден в дереве B
  local oa ob
  oa="$(env XDG_STATE_HOME="$WORK/hbase" HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$WORKSHOP" --probe "$R1" 2>/dev/null | grep -F 'STATE: ' | sed 's/^STATE: //')"
  ob="$(env XDG_STATE_HOME="$WORK/hbase" HARNESS_PROJECT_LAYER_ROOT="$LAYER2" bash "$WORKSHOP" --probe "$R2" 2>/dev/null | grep -F 'STATE: ' | sed 's/^STATE: //')"
  [ "$oa" != "$ob" ] || return 1
  printf 'marker-a' > "$oa/home/marker-055" 2>/dev/null || mkdir -p "$oa/home" && printf 'marker-a' > "$oa/home/marker-055"
  ! find "$ob" -name 'marker-055' -print -quit 2>/dev/null | grep -q .
}
c3h() { # И-5/И-6: живой лок → rc 1 W3 (rc изолирован от pipefail: подстановка)
  mkdir -p "$WORK/hbase/dev-harness-projects/p1/sessions" 2>/dev/null
  sleep 30 & HOLDER=$!
  printf '%s\n' "$HOLDER" > "$HLOCK"
  local o rc
  o="$(env XDG_STATE_HOME="$WORK/hbase" HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$WORKSHOP" --probe "$R1" 2>&1)"; rc=$?
  kill "$HOLDER" 2>/dev/null; wait "$HOLDER" 2>/dev/null
  [ "$rc" -ne 0 ] && printf '%s' "$o" | grep -Fq "$W3"
}
c4h() { # И-5: мёртвый лок замещается — rc 0
  sleep 30 & DEAD=$!; kill "$DEAD" 2>/dev/null; wait "$DEAD" 2>/dev/null
  mkdir -p "$WORK/hbase/dev-harness-projects/p1/sessions" 2>/dev/null
  printf '%s\n' "$DEAD" > "$HLOCK"
  env XDG_STATE_HOME="$WORK/hbase" HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$WORKSHOP" --probe "$R1" >/dev/null 2>&1
}
c5h() { # И-6: probe не оставляет лок
  rm -f "$HLOCK"
  env XDG_STATE_HOME="$WORK/hbase" HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$WORKSHOP" --probe "$R1" >/dev/null 2>&1
  [ ! -f "$HLOCK" ]
}
c6h() { # И-3/И-4: метеринг-строка с проектом и ролью
  env XDG_STATE_HOME="$WORK/hbase" HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$WORKSHOP" --probe "$R1" 2>/dev/null | grep -Fq 'METERING: project=p1 role=orchestrator'
}
c7h() { # И-7/И-8: packs отсутствует → [] с origin project
  env HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$RESOLVER" --repo "$R7" 2>/dev/null | jq -e '.packs.value == [] and .packs.origin == "project"' >/dev/null 2>&1
}
c8h() { # И-7: НЕ-список → P6 (rc изолирован: подстановка)
  local o
  o="$(env HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$RESOLVER" --repo "$R8" 2>&1)"
  printf '%s' "$o" | grep -Fq 'profile ОТКАЗ: значение вне алфавита: packs:'
}
c9h() { # И-7: элемент вне класса → P6 с именем элемента (rc изолирован: подстановка)
  local o
  o="$(env HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$RESOLVER" --repo "$R9" 2>&1)"
  printf '%s' "$o" | grep -Fq 'profile ОТКАЗ: значение вне алфавита: packs: Bad Pack!'
}
c10h() { # И-1: projectId вне класса → W4 (rc изолирован: подстановка)
  local o
  layer_make "$WORK/layer-bad" 'Bad/Id'
  o="$(env XDG_STATE_HOME="$WORK/hbase" HARNESS_PROJECT_LAYER_ROOT="$WORK/layer-bad" bash "$WORKSHOP" --probe "$R1" 2>&1)"
  printf '%s' "$o" | grep -Fq 'projectId вне класса пути'
}


hcell c1h c1h; hcell c2h c2h; hcell c3h c3h; hcell c4h c4h; hcell c5h c5h
hcell c6h c6h; hcell c7h c7h; hcell c8h c8h; hcell c9h c9h; hcell c10h c10h
[ "$HSEEN" -eq 10 ] || die_pack "счёт честных клеток ≠ 10: $HSEEN"
[ "$HONEST" -eq "$HSEEN" ] || { printf 'честная часть: %s из %s\n' "$HONEST" "$HSEEN" >&2; exit 1; }
printf 'честная часть: 10/10 зелёная; предъявлений: стабы 9/9 + дифф 9/9 + честные 10/10\n'
exit 0
