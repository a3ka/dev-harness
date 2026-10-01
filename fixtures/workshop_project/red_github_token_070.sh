#!/usr/bin/env bash
# 070-БАТАРЕЯ — GitHub-чтение (Б-2): read-only токен ODELIX_GITHUB_TOKEN из
# дома ВНЕ репозитория (~/.config/odelix/github.env) в сессию лаунчером
# workshop (контракт 070; боль пилота Б-2 odelix-stack ODX-STK-001; решение
# владельца — чекпойнт #61, правка (3): fine-grained PAT odelixhq ТОЛЬКО
# ЧТЕНИЕ, лаунчер передаёт токен в сессию, первый шаг — только чтение).
#
# Дом семьи — fixtures/workshop_project/ (probe-only, 034), раннер —
# fixtures/_krasnye_070.sh. До-заморозочный носитель закоммичен АРХИТЕКТОРОМ
# (красные предъявления ДО круга критика; прецедент 058).
#
# Структура (058-прецедент):
#   1. СТАБ-ПАК (7 обманных стабов лаунчер-шага, ручки STUB_*) — зелёный
#      ДО и ПОСЛЕ реализации: каждый стаб умирает на СВОЕЙ клетке;
#      диффпроба — те же стабы БЕЗ ручек проходят те же клетки
#      (ловля предикатом, не случаем).
#   2. г0 «предмет отсутствует» — ПОВЕДЕНЧЕСКИЙ fail-fast: живой
#      `workshop --probe` на toy-проекте с токеном в toy-доме НЕ печатает
#      строку `GITHUB: read` → честная часть не исполняется, rc 1.
#   3. ЧЕСТНАЯ ЧАСТЬ (клетки к1..к7) — зелёная ПОСЛЕ реализации:
#      к1 баннер read в probe без значения в выводе; к2 токен+режим в env
#      ребёнка сессии (стаб-omp); к3 нет дома → offline явный, переменной
#      в env нет; к4 внешний env-токен побеждает файл; к5 нуль копий
#      значения по toy-репо, PSTATE и дереву мастерской; к6 пустое
#      значение = offline; к7 дев-вход (без проекта) — та же одна функция.
#
# Привязки обманных стабов к входам (Н-39 — живут ЗДЕСЬ, в коде батареи,
# не в прозе контракта; каждый стаб красен на входе, где его дефект
# НАБЛЮДАЕМ, и честен без ручки на том же входе):
#   s1 STUB_PRINT_VALUE  «печатает значение»    — красен на с1 (токен в
#        доме): значение в выводе прогона = утечка в лог.
#   s2 STUB_WRITE_FILE   «дописывает в файл»    — красен на с2 (токен в
#        доме): копия строки ODELIX_GITHUB_TOKEN=… в .env дерева
#        (bootstrap_env-стиль копирования секрета в дерево).
#   s3 STUB_SILENT       «молчит без токена»    — красен на с3 (дома нет):
#        строки `GITHUB: offline` нет = молчаливая деградация (боль Б-2:
#        NOT_RUN без пометки).
#   s4 STUB_OVERWRITE    «затирает заданное»    — красен на с4 (внешний
#        env-токен A + файл B): в env ребёнка ушёл B, а не A.
#   s5 STUB_REQUIRE      «требует токен»        — красен на с5 (дома нет):
#        rc≠0 фатального отказа вместо явной offline-деградации.
#   s6 STUB_NO_EXPORT    «не доходит до сессии» — красен на с6 (токен в
#        доме): ODELIX_GITHUB_TOKEN нет в env-дампе ребёнка = сама боль Б-2.
#   s7 STUB_NO_MODE      «режим неявный»        — красен на с7 (токен в
#        доме): маркер HARNESS_GITHUB_MODE не дошёл до ребёнка сессии.
#
# Демаркация контрпримеров (уроки 019): КОНФОРМНЫЕ входы по грамматике
# предмета — github.env несёт текстовые строки KEY=VALUE (та же грамматика,
# что bootstrap_env workshop:124-135: разрез по первому «=», срез парных
# кавычек), ключ ODELIX_GITHUB_TOKEN, значение — непустая строка после
# среза; конформны также ОТСУТСТВИЕ файла, ПУСТОЕ значение и непустой
# внешний env-токен (CI/фикстуры). Значения toy-токенов СЛУЧАЙНЫ на каждый
# прогон (инвариантность к значениям): стаб с зашитым литералом значения
# пройти клетку не может. Валидный контрпример = инвариантность к значениям
# ∧ расхождение честного и стаба на КОНФОРМНОМ входе.
#
# ГИГИЕНА СЕКРЕТОВ: батарея НИКОГДА не читает живой ~/.config/odelix/… —
# все прогоны идут с HOME=toy-каталог батареи; ambient ODELIX_GITHUB_TOKEN и
# HARNESS_GITHUB_MODE сняты до начала; grep'ы ищут ТОЛЬКО toy-значения.
#
# Прогон: bash red_github_token_070.sh [корень worktree]
#   rc 0 — стаб-пак пойман (7/7) И диффпроба (7/7) И честная часть зелёная.
#   rc 1 — расхождение / предмет отсутствует (г0, ДО реализации).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="${1:-$(cd "$HERE/../.." && pwd -P)}"
WORKSHOP="${WORKSHOP:-$ROOT/workshop}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
die_pack() { printf '070-батарея ОТКАЗ: %s\n' "$*" >&2; exit 1; }
command -v git >/dev/null 2>&1 || die_pack "нет git"
command -v jq >/dev/null 2>&1 || die_pack "нет jq"
command -v sha256sum >/dev/null 2>&1 || die_pack "нет sha256sum"
command -v node >/dev/null 2>&1 || die_pack "нет node"

# Ложные зелёные от протекающего окружения (055/058-прецедент) + гигиена
# секретов: живые значения сессии в батарею не попадают.
unset HARNESS_SESSION_HOME HARNESS_SCRATCH METERING_PROJECT METERING_ROLE
unset ODELIX_GITHUB_TOKEN HARNESS_GITHUB_MODE

# Случайные toy-значения (демаркация: инвариантность к значениям).
TOY_TOKEN="github_pat_070_$(printf '%s' "${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}" | sha256sum | cut -c1-16)"
TOY_EXT="github_pat_070ext_$(printf '%s' "${RANDOM}${RANDOM}${RANDOM}" | sha256sum | cut -c1-12)"
TOY_FILE="github_pat_070file_$(printf '%s' "${RANDOM}${RANDOM}${RANDOM}" | sha256sum | cut -c1-12)"
[ "$TOY_TOKEN" != "$TOY_EXT" ] && [ "$TOY_TOKEN" != "$TOY_FILE" ] && [ "$TOY_EXT" != "$TOY_FILE" ] \
  || die_pack "генератор toy-токенов выдал коллизию"

# ── строители toy-мира (полный профиль 054/058 — живой резолвер HEAD) ────────
layer_make() { # $1=корень слоя $2=projectId
  mkdir -p "$1/registry"
  printf '{"schemaVersion":1,"version":"v10","projectId":"%s","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"cargo test","build":"cargo build","typecheck":"cargo check","lint":"cargo clippy"},"git":{"canonicalRemote":"git@host:p1.git"},"ci":{"workflow":".github/workflows/ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":[]}}}' "$2" > "$1/registry/harness-project.json"
}
repo_make() { # $1=корень репо $2=repoId
  local r="$1"
  mkdir -p "$r/config"
  git -C "$r" init -q
  git -C "$r" config receive.denyCurrentBranch refuse
  printf '{"schemaVersion":1,"repoId":"%s","language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"ci":{"workflow":".github/workflows/ci.yml"},"git":{"canonicalRemote":"git@host:r1.git"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}' "$2" > "$r/harness.project.json"
  printf '{"version":"v10"}\n' > "$r/config/harness_pin.json"
  printf 'METERING_PROXY_URL=http://toy.invalid:1\n' > "$r/.env"
  # С2-миграция toy-миров (контракт 059): объявленный CI-toy-файл обязан
  # существовать — резолвер проверяет его на REPO_ABS (арбитраж 059-к3 С2).
  mkdir -p "$r/.github/workflows"
  printf 'name: toy ci\n' > "$r/.github/workflows/ci.yml"
}
LAYER="$WORK/layer-p1"; layer_make "$LAYER" p1
R1="$WORK/repo-p1"; repo_make "$R1" r1

# ── СТАБ-OMP: субъект живого режима (честные клетки к2/к3/к4/к7) ────────────
# Пишет факт СВОЕГО окружения (env-дамп ребёнка сессии) — прецедент 058
# (red_sharing_agentdb.sh:146-155): экспорты лаунчера ДО exec наблюдаются
# именно с этой стороны границы exec.
SHIMDIR="$WORK/shimbin"; mkdir -p "$SHIMDIR"
cat > "$SHIMDIR/omp" <<'SHIM'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then printf 'omp/v10\n'; exit 0; fi
printf 'pid=%s\n' "$$" > "$SHIM_OUT"
env | LC_ALL=C sort > "$SHIM_ENV"
exit 0
SHIM
chmod +x "$SHIMDIR/omp"

# ── дом GitHub-токена toy-пользователя: $1/.config/odelix/github.env ────────
ghome_make() { # $1=база HOME; $2=значение (умолчание TOY_TOKEN; «» — пустое)
  mkdir -p "$1/.config/odelix"
  printf 'ODELIX_GITHUB_TOKEN=%s\n' "${2-$TOY_TOKEN}" > "$1/.config/odelix/github.env"
}

# ── прогоны живого workshop (ожидания — в ПАМЯТИ, правило 8) ─────────────────
probe_run() { # $1=база HOME (toy-дом токена); $2=выходной файл
  env HOME="$1" XDG_STATE_HOME="$1.state" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    bash "$WORKSHOP" --probe "$R1" > "$2" 2>&1
}
live_run() { # $1=база HOME; $2=файл env-дампа SHIM; $3=внешний токен (опц.)
  if [ $# -ge 3 ] && [ -n "$3" ]; then
    env PATH="$SHIMDIR:$PATH" HOME="$1" XDG_STATE_HOME="$1.state" \
      HARNESS_PROJECT_LAYER_ROOT="$LAYER" ODELIX_GITHUB_TOKEN="$3" \
      ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key METERING_PROXY_TOKEN=toy-token \
      METERING_PROXY_URL=http://toy.invalid:1 \
      SHIM_ENV="$2" SHIM_OUT="$2.pid" bash "$WORKSHOP" "$R1"
  else
    env PATH="$SHIMDIR:$PATH" HOME="$1" XDG_STATE_HOME="$1.state" \
      HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
      ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key METERING_PROXY_TOKEN=toy-token \
      METERING_PROXY_URL=http://toy.invalid:1 \
      SHIM_ENV="$2" SHIM_OUT="$2.pid" bash "$WORKSHOP" "$R1"
  fi
}
dev_run() { # $1=база HOME; $2=файл env-дампа SHIM — дев-вход (без проекта)
  env PATH="$SHIMDIR:$PATH" HOME="$1" XDG_STATE_HOME="$1.state" \
    ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key METERING_PROXY_TOKEN=toy-token \
    METERING_PROXY_URL=http://toy.invalid:1 \
    SHIM_ENV="$2" SHIM_OUT="$2.pid" bash "$WORKSHOP"
}

# ── ОБМАННЫЙ СТАБ лаунчер-шага 070 ───────────────────────────────────────────
# Реализует шаг GitHub-токена по спецификации контракта (чтение
# ${HOME}/.config/odelix/github.env, уже заданное НЕ затирается, экспорт
# ODELIX_GITHUB_TOKEN + HARNESS_GITHUB_MODE, баннер `GITHUB: read|offline`,
# нуль копий значения в файлы, значение НЕ печатается). Ручка STUB_*
# включает РОВНО ОДИН дефект; без ручек стаб честен на всех клетках.
# Дамп env в $STUB_ENV = окружение, которое получил бы ребёнок сессии.
cat > "$WORK/stub-workshop-070" <<'STUB'
#!/usr/bin/env bash
set -uo pipefail
GH_HOME="${HOME:?нет HOME}/.config/odelix/github.env"
gh_read() { # печатает значение из дома или пусто
  [ -f "$GH_HOME" ] || return 0
  local k v
  while IFS='=' read -r k v; do
    case "$k" in ODELIX_GITHUB_TOKEN)
      v="$(printf '%s' "$v" | sed 's/^["'"'"']//;s/["'"'"']$//')"
      [ -n "$v" ] && printf '%s' "$v" && return 0 ;;
    esac
  done < "$GH_HOME"
  return 0
}
TOK="${ODELIX_GITHUB_TOKEN:-}"; MODE=""
if [ -n "$TOK" ]; then
  MODE=read
else
  TOK="$(gh_read)"
  [ -n "$TOK" ] && MODE=read
fi
[ -n "$MODE" ] || MODE=offline
# s5 «требует токен»: фатальный отказ вместо явной offline-деградации
if [ "$MODE" = offline ] && [ -n "${STUB_REQUIRE:-}" ]; then
  printf 'ОТКАЗ: нет ODELIX_GITHUB_TOKEN — GitHub-чтение обязательно\n' >&2
  exit 1
fi
# s4 «затирает заданное»: значение файла побеждает внешний env
if [ -n "${STUB_OVERWRITE:-}" ]; then
  file_tok="$(gh_read)"
  [ -n "$file_tok" ] && TOK="$file_tok"
fi
# s6 «не доходит до сессии»: значение вычислено, но НЕ экспортировано
[ -n "${STUB_NO_EXPORT:-}" ] || [ -z "$TOK" ] || export ODELIX_GITHUB_TOKEN="$TOK"
# s7 «режим неявный»: маркер режима не доходит до сессии
[ -n "${STUB_NO_MODE:-}" ] || export HARNESS_GITHUB_MODE="$MODE"
# s2 «дописывает в файл»: копия значения в .env дерева (bootstrap_env-стиль)
if [ -n "${STUB_WRITE_FILE:-}" ] && [ -n "$TOK" ]; then
  printf 'ODELIX_GITHUB_TOKEN=%s\n' "$TOK" >> "${STUB_TREE:?нет STUB_TREE}/.env"
fi
# баннер (probe-наблюдаемая поверхность); s1 «печатает значение»
if [ "$MODE" = read ]; then
  if [ -n "${STUB_PRINT_VALUE:-}" ]; then
    printf 'GITHUB: read (%s)\n' "$TOK"
  else
    printf 'GITHUB: read\n'
  fi
else
  # s3 «молчит без токена»: строки GITHUB: нет вовсе
  [ -n "${STUB_SILENT:-}" ] || printf 'GITHUB: offline\n'
fi
# граница exec: дамп окружения ребёнка сессии
env | LC_ALL=C sort > "${STUB_ENV:?нет STUB_ENV}"
exit 0
STUB
chmod +x "$WORK/stub-workshop-070"

# ── СТАБ-ПАК: клетки с1..с7, каждая ловит СВОЙ стаб; счёт напечатан ──────────
check_c1() { # s1 «печатает значение»: значение в выводе = утечка в лог
  local b="$WORK/c1"; rm -rf "$b"; mkdir -p "$b"
  ghome_make "$b"
  local o="$WORK/c1.out"
  env HOME="$b" STUB_ENV="$WORK/c1.env" STUB_PRINT_VALUE=1 \
    bash "$WORK/stub-workshop-070" > "$o" 2>&1
  grep -Fq -- "$TOY_TOKEN" "$o"
}
diff_c1() {
  local b="$WORK/c1d"; rm -rf "$b"; mkdir -p "$b"
  ghome_make "$b"
  local o="$WORK/c1d.out"
  env HOME="$b" STUB_ENV="$WORK/c1d.env" \
    bash "$WORK/stub-workshop-070" > "$o" 2>&1
  grep -Fxq 'GITHUB: read' "$o" && ! grep -Fq -- "$TOY_TOKEN" "$o"
}
check_c2() { # s2 «дописывает в файл»: копия строки токена в .env дерева
  local b="$WORK/c2"; rm -rf "$b"; mkdir -p "$b/tree"
  ghome_make "$b"
  : > "$b/tree/.env"
  env HOME="$b" STUB_ENV="$WORK/c2.env" STUB_TREE="$b/tree" STUB_WRITE_FILE=1 \
    bash "$WORK/stub-workshop-070" > "$WORK/c2.out" 2>&1
  grep -Fq -- "ODELIX_GITHUB_TOKEN=$TOY_TOKEN" "$b/tree/.env"
}
diff_c2() {
  local b="$WORK/c2d"; rm -rf "$b"; mkdir -p "$b/tree"
  ghome_make "$b"
  : > "$b/tree/.env"
  env HOME="$b" STUB_ENV="$WORK/c2d.env" STUB_TREE="$b/tree" \
    bash "$WORK/stub-workshop-070" > "$WORK/c2d.out" 2>&1
  ! grep -Fq -- "ODELIX_GITHUB_TOKEN=$TOY_TOKEN" "$b/tree/.env" \
    && grep -Fxq 'GITHUB: read' "$WORK/c2d.out"
}
check_c3() { # s3 «молчит без токена»: строки offline-разметки нет
  local b="$WORK/c3"; rm -rf "$b"; mkdir -p "$b"   # дома НЕТ
  env HOME="$b" STUB_ENV="$WORK/c3.env" STUB_SILENT=1 \
    bash "$WORK/stub-workshop-070" > "$WORK/c3.out" 2>&1
  ! grep -Fxq 'GITHUB: offline' "$WORK/c3.out"
}
diff_c3() {
  local b="$WORK/c3d"; rm -rf "$b"; mkdir -p "$b"
  local rc=0
  env HOME="$b" STUB_ENV="$WORK/c3d.env" \
    bash "$WORK/stub-workshop-070" > "$WORK/c3d.out" 2>&1 || rc=$?
  [ "$rc" -eq 0 ] && grep -Fxq 'GITHUB: offline' "$WORK/c3d.out" \
    && ! grep -q '^ODELIX_GITHUB_TOKEN=' "$WORK/c3d.env" \
    && grep -Fxq 'HARNESS_GITHUB_MODE=offline' "$WORK/c3d.env"
}
check_c4() { # s4 «затирает заданное»: в сессию ушёл файл-B, а не внешний A
  local b="$WORK/c4"; rm -rf "$b"; mkdir -p "$b"
  ghome_make "$b" "$TOY_FILE"
  env HOME="$b" ODELIX_GITHUB_TOKEN="$TOY_EXT" STUB_ENV="$WORK/c4.env" STUB_OVERWRITE=1 \
    bash "$WORK/stub-workshop-070" > "$WORK/c4.out" 2>&1
  grep -Fxq -- "ODELIX_GITHUB_TOKEN=$TOY_FILE" "$WORK/c4.env"
}
diff_c4() {
  local b="$WORK/c4d"; rm -rf "$b"; mkdir -p "$b"
  ghome_make "$b" "$TOY_FILE"
  env HOME="$b" ODELIX_GITHUB_TOKEN="$TOY_EXT" STUB_ENV="$WORK/c4d.env" \
    bash "$WORK/stub-workshop-070" > "$WORK/c4d.out" 2>&1
  grep -Fxq -- "ODELIX_GITHUB_TOKEN=$TOY_EXT" "$WORK/c4d.env" \
    && grep -Fxq 'HARNESS_GITHUB_MODE=read' "$WORK/c4d.env"
}
check_c5() { # s5 «требует токен»: rc≠0 отказа вместо деградации
  local b="$WORK/c5"; rm -rf "$b"; mkdir -p "$b"   # дома НЕТ
  local rc=0
  env HOME="$b" STUB_ENV="$WORK/c5.env" STUB_REQUIRE=1 \
    bash "$WORK/stub-workshop-070" > "$WORK/c5.out" 2>&1 || rc=$?
  [ "$rc" -ne 0 ]
}
diff_c5() {
  local b="$WORK/c5d"; rm -rf "$b"; mkdir -p "$b"
  local rc=0
  env HOME="$b" STUB_ENV="$WORK/c5d.env" \
    bash "$WORK/stub-workshop-070" > "$WORK/c5d.out" 2>&1 || rc=$?
  [ "$rc" -eq 0 ] && grep -Fxq 'GITHUB: offline' "$WORK/c5d.out"
}
check_c6() { # s6 «не доходит до сессии»: переменной нет в env-дампе ребёнка
  local b="$WORK/c6"; rm -rf "$b"; mkdir -p "$b"
  ghome_make "$b"
  env HOME="$b" STUB_ENV="$WORK/c6.env" STUB_NO_EXPORT=1 \
    bash "$WORK/stub-workshop-070" > "$WORK/c6.out" 2>&1
  ! grep -q '^ODELIX_GITHUB_TOKEN=' "$WORK/c6.env"
}
diff_c6() {
  local b="$WORK/c6d"; rm -rf "$b"; mkdir -p "$b"
  ghome_make "$b"
  env HOME="$b" STUB_ENV="$WORK/c6d.env" \
    bash "$WORK/stub-workshop-070" > "$WORK/c6d.out" 2>&1
  grep -Fxq -- "ODELIX_GITHUB_TOKEN=$TOY_TOKEN" "$WORK/c6d.env" \
    && grep -Fxq 'HARNESS_GITHUB_MODE=read' "$WORK/c6d.env"
}
check_c7() { # s7 «режим неявный»: маркера режима нет в env-дампе ребёнка
  local b="$WORK/c7"; rm -rf "$b"; mkdir -p "$b"
  ghome_make "$b"
  env HOME="$b" STUB_ENV="$WORK/c7.env" STUB_NO_MODE=1 \
    bash "$WORK/stub-workshop-070" > "$WORK/c7.out" 2>&1
  ! grep -Fxq 'HARNESS_GITHUB_MODE=read' "$WORK/c7.env"
}
diff_c7() {
  local b="$WORK/c7d"; rm -rf "$b"; mkdir -p "$b"
  ghome_make "$b"
  env HOME="$b" STUB_ENV="$WORK/c7d.env" \
    bash "$WORK/stub-workshop-070" > "$WORK/c7d.out" 2>&1
  grep -Fxq -- "ODELIX_GITHUB_TOKEN=$TOY_TOKEN" "$WORK/c7d.env" \
    && grep -Fxq 'HARNESS_GITHUB_MODE=read' "$WORK/c7d.env"
}

CAUGHT=0; SEEN=0; DIFF=0; DIFFSEEN=0
for n in c1 c2 c3 c4 c5 c6 c7; do
  SEEN=$((SEEN+1))
  if "check_$n"; then CAUGHT=$((CAUGHT+1)); else printf '070-батарея: клетка %s НЕ поймала свой стаб\n' "$n" >&2; fi
  DIFFSEEN=$((DIFFSEEN+1))
  if "diff_$n"; then DIFF=$((DIFF+1)); else printf '070-батарея: диффпроба %s — стаб без ручки упал\n' "$n" >&2; fi
done
[ "$SEEN" -eq 7 ] || die_pack "счёт стаб-клеток ≠ 7: $SEEN (пустая/лишняя выборка — красная)"
[ "$CAUGHT" -eq 7 ] || { printf 'стаб-пак: поймано %s из %s\n' "$CAUGHT" "$SEEN" >&2; exit 1; }
[ "$DIFF" -eq 7 ] || { printf 'диффпроба: прошли %s из %s\n' "$DIFF" "$DIFFSEEN" >&2; exit 1; }
printf 'стаб-пак: 7/7 поймано, диффпроба 7/7 — различимость жива (Н-39)\n'

# ── г0: предмет отсутствует — ПОВЕДЕНЧЕСКИЙ fail-fast (054/055-прецедент) ────
# Живой workshop --probe на toy-проекте с токеном в toy-доме обязан печатать
# строку `GITHUB: read`. Отказ/отсутствие строки = предмет не реализован:
# честная часть не исполняется, rc 1 (ДО реализации — по конструкции).
g0_rc=0
g0b="$WORK/g0"; rm -rf "$g0b"; mkdir -p "$g0b"
ghome_make "$g0b"
probe_run "$g0b" "$WORK/g0.out" || g0_rc=$?
if [ "$g0_rc" -ne 0 ]; then
  sed -n '1,15p' "$WORK/g0.out" >&2 || true
  die_pack "probe toy-мира упал rc=$g0_rc — мир батареи сломан, не предмет"
fi
if ! grep -Fxq 'GITHUB: read' "$WORK/g0.out"; then
  printf 'ОТКАЗ: предмет отсутствует: %s на probe с токеном в доме не печатает строку `GITHUB: read` (шаг GitHub-чтения — контракт 070)\n' "$WORKSHOP" >&2
  exit 1
fi

# ── ЧЕСТНАЯ ЧАСТЬ (клетки к1..к7; зелёная ПОСЛЕ реализации) ──────────────────
HONEST=0; HSEEN=0
hcell() { local n="$1"; shift; HSEEN=$((HSEEN+1)); "$@" && HONEST=$((HONEST+1)) || printf '070-батарея: честная клетка %s красная\n' "$n" >&2; }

k1() { # баннер read в probe; значения НЕТ в выводе (нуль в логах)
  local b="$WORK/k1"; rm -rf "$b"; mkdir -p "$b"
  ghome_make "$b"
  local out="$WORK/k1.out" rc=0
  probe_run "$b" "$out" || rc=$?
  [ "$rc" -eq 0 ] && grep -Fxq 'GITHUB: read' "$out" \
    && ! grep -Fq -- "$TOY_TOKEN" "$out"
}
k2() { # live: токен+режим в env ребёнка сессии; запуск rc 0; значения нет в выводе
  local b="$WORK/k2"; rm -rf "$b"; mkdir -p "$b"
  ghome_make "$b"
  local rc=0
  live_run "$b" "$WORK/k2.env" > "$WORK/k2.out" 2>&1 || rc=$?
  [ "$rc" -eq 0 ] \
    && grep -Fxq -- "ODELIX_GITHUB_TOKEN=$TOY_TOKEN" "$WORK/k2.env" \
    && grep -Fxq 'HARNESS_GITHUB_MODE=read' "$WORK/k2.env" \
    && ! grep -Fq -- "$TOY_TOKEN" "$WORK/k2.out"
}
k3() { # нет дома: probe rc 0 + offline-строка; в env сессии переменной НЕТ
      # (unset, не пусто), режим offline — деградация явная, не фатальная
  local b="$WORK/k3a"; rm -rf "$b"; mkdir -p "$b"
  local out="$WORK/k3.out" rc=0
  probe_run "$b" "$out" || rc=$?
  [ "$rc" -eq 0 ] && grep -Fxq 'GITHUB: offline' "$out" || return 1
  local b2="$WORK/k3b"; rm -rf "$b2"; mkdir -p "$b2"
  local rc2=0
  live_run "$b2" "$WORK/k3.env" > "$WORK/k3b.out" 2>&1 || rc2=$?
  [ "$rc2" -eq 0 ] \
    && ! grep -q '^ODELIX_GITHUB_TOKEN=' "$WORK/k3.env" \
    && grep -Fxq 'HARNESS_GITHUB_MODE=offline' "$WORK/k3.env"
}
k4() { # внешний env-токен A побеждает файл-B (уже заданное НЕ затирается)
  local b="$WORK/k4"; rm -rf "$b"; mkdir -p "$b"
  ghome_make "$b" "$TOY_FILE"
  local rc=0
  live_run "$b" "$WORK/k4.env" "$TOY_EXT" > "$WORK/k4.out" 2>&1 || rc=$?
  [ "$rc" -eq 0 ] \
    && grep -Fxq -- "ODELIX_GITHUB_TOKEN=$TOY_EXT" "$WORK/k4.env" \
    && ! grep -Fq -- "ODELIX_GITHUB_TOKEN=$TOY_FILE" "$WORK/k4.env" \
    && grep -Fxq 'HARNESS_GITHUB_MODE=read' "$WORK/k4.env"
}
k5() { # нуль копий: после live-запуска значение НЕ найдено ни в toy-репо,
      # ни в PSTATE, ни в дереве мастерской (пустая выборка grep rc 1 = чисто)
  local b="$WORK/k5"; rm -rf "$b"; mkdir -p "$b"
  ghome_make "$b"
  local rc=0
  live_run "$b" "$WORK/k5.env" > "$WORK/k5.out" 2>&1 || rc=$?
  [ "$rc" -eq 0 ] || return 1
  ! grep -rF -- "$TOY_TOKEN" "$R1" >/dev/null 2>&1 \
    && ! grep -rF -- "$TOY_TOKEN" "$b.state" >/dev/null 2>&1 \
    && ! grep -rF --exclude-dir=.git -- "$TOY_TOKEN" "$ROOT" >/dev/null 2>&1
}
k6() { # пустое значение = offline (пусто НЕ есть задано)
  local b="$WORK/k6"; rm -rf "$b"; mkdir -p "$b"
  ghome_make "$b" ""
  local out="$WORK/k6.out" rc=0
  probe_run "$b" "$out" || rc=$?
  [ "$rc" -eq 0 ] && grep -Fxq 'GITHUB: offline' "$out"
}
k7() { # дев-вход (без проекта): та же одна функция — токен+режим в env сессии
  local b="$WORK/k7"; rm -rf "$b"; mkdir -p "$b"
  ghome_make "$b"
  local rc=0
  dev_run "$b" "$WORK/k7.env" > "$WORK/k7.out" 2>&1 || rc=$?
  [ "$rc" -eq 0 ] \
    && grep -Fxq -- "ODELIX_GITHUB_TOKEN=$TOY_TOKEN" "$WORK/k7.env" \
    && grep -Fxq 'HARNESS_GITHUB_MODE=read' "$WORK/k7.env"
}

hcell к1 k1
hcell к2 k2
hcell к3 k3
hcell к4 k4
hcell к5 k5
hcell к6 k6
hcell к7 k7
[ "$HSEEN" -eq 7 ] || die_pack "счёт честных клеток ≠ 7: $HSEEN (пустая/лишняя выборка — красная)"
[ "$HONEST" -eq "$HSEEN" ] || { printf 'честная часть: %s из %s\n' "$HONEST" "$HSEEN" >&2; exit 1; }
printf 'честная часть: 7/7 зелёная; предъявлений: стабы 7/7 + дифф 7/7 + честные 7/7\n'
exit 0
