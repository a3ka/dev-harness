#!/usr/bin/env bash
# 058-БАТАРЕЯ — шаринг agent.db: симлинк PROJDB на дев-базу DEVDB в проектной
# ветви workshop (контракт 058, боль пилота №1).
#
# Дом семьи — fixtures/workshop_project/ (probe-only, 034), раннер —
# fixtures/_krasnye_058.sh. До-заморозочный носитель закоммичен АРХИТЕКТОРОМ
# кругом 2 (закрытие блокера 1 вердикта contracts-058-v1: красные предъявления
# ДО круга критика, AGENTS.md:131-136; прецедент 045 — батарея+раннер в
# architect-зоне контракта).
#
# Структура (054/055-прецедент):
#   1. СТАБ-ПАК (9 обманных стабов, ручки STUB_*) — зелёный ДО и ПОСЛЕ
#      реализации: каждый стаб умирает на СВОЕЙ клетке; дифференциальная
#      проба — те же стабы БЕЗ ручек проходят свои клетки (ловля
#      предикатом, не случаем).
#   2. г0 «предмет отсутствует» — FAIL-FAST до честной части: в workshop нет
#      шага AGENTDB → честная часть не исполняется, rc 1 (ДО реализации).
#   3. ЧЕСТНАЯ ЧАСТЬ (клетки к1..к11, к13..к16) — зелёная ПОСЛЕ реализации.
#      Фикс-раунд-1 по вердикту contracts-058-v1 (пост-заморозочное усиление
#      гейта, прецедент 005): к12 (И-6) ИСПОЛНИМАЯ — dev-вход с безопасным
#      omp-shim (F2); к15 — второй projectId (F1: зашитая константа p1
#      обязана краснеть). Фикс-раунд-2 по вердикту contracts-058-v2 и арбитраж
#      058/N1 (РЕШЕНИЕ 773938b, п.2): к15 — projectId СЛУЧАЙНЫЙ из ПОЛНОЙ
#      грамматики поля без фиксированного литерала — мутант с любым зашитым
#      ЛИТЕРАЛОМ/набором id краснеет; предикат, подогнанный под распределение
#      выборки, — именованный остаток, закрывается чтением исходника (арбитраж
#      058/N1); к16 — симлинк-
#      родитель $PSTATE/home → внешний каталог: именованный отказ ДО
#      материализации любого дочернего состояния, agent.db не материализуется
#      по канонической цепочке вне PSTATE-корня (N2, И-2) — зелёное к16 на
#      объединении с фикс-веткой N2 (wip/058/implementer), красное до неё.
#
# Привязки обманных стабов к клеткам (Н-39 — живут ЗДЕСЬ, в коде батареи,
# не в прозе контракта; каждый стаб красен на входе, где его дефект
# НАБЛЮДАЕМ, и честен без ручки на том же входе):
#   s1 STUB_ALWAYS_CREATE   «всегда создаёт»      — красен на к2 (C2: ссылка
#        на отсутствующий DEVDB создана); честно: ничего не создавать, A2.
#   s2 STUB_COPY            «копия»               — красен на к1 (PROJDB —
#        регулярный файл, не ссылка); честно: ln -s, A1.
#   s3 STUB_SHARE_DIR       «шарит каталог»       — красен на к3 (ссылка —
#        каталог agent/, не файл PROJDB; маркеры дев-зоны видны); честно:
#        ровно одна ссылка и её путь PROJDB.
#   s4 STUB_RECREATE        «пересоздаёт»         — красен на к4 (inode
#        валидной ссылки изменился); честно: L1 не трогает ссылку.
#   s5 STUB_NO_FIX          «не чинит цель»       — красен на к5 (readlink
#        остался старым при живом DEVDB); честно: ln -sfn на текущий DEVDB.
#   s6 STUB_CLOBBER         «затирает регулярный» — красен на к7 (непустой
#        файл заменён); честно: R1 не трогать, W8 + A2.
#   s7 STUB_RM_LINK         «сносит любую ссылку» — красен на к13 (L3a:
#        работающая ссылка на чужую живую цель удалена при отсутствующем
#        DEVDB, A2 вместо фактического readlink); честно: L3a не трогать,
#        A1(readlink). ОБХОД из вердикта 058-v1 (блокер 3) закрыт здесь.
#   s8 STUB_NO_PROBE_STEP   «probe без шага»      — красен на к1 (probe не
#        материализует ссылку и не печатает баннер); честно: probe и живой
#        — один код (Граница-4).
#   s9 STUB_SILENT          «молчит без баннера»  — красен на к1 (строки
#        AGENTDB нет); честно: баннер несёт фактическую ветвь.
#
# Прогон: bash red_sharing_agentdb.sh [корень worktree]
#   rc 0 — стаб-пак пойман (9/9) И диффпроба (9/9) И честная часть зелёная.
#   rc 1 — расхождение / предмет отсутствует (г0, ДО реализации).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="${1:-$(cd "$HERE/../.." && pwd -P)}"
WORKSHOP="${WORKSHOP:-$ROOT/workshop}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
die_pack() { printf '058-батарея ОТКАЗ: %s\n' "$*" >&2; exit 1; }
command -v git >/dev/null 2>&1 || die_pack "нет git"
command -v jq >/dev/null 2>&1 || die_pack "нет jq"
command -v sha256sum >/dev/null 2>&1 || die_pack "нет sha256sum"
command -v readlink >/dev/null 2>&1 || die_pack "нет readlink"
command -v stat >/dev/null 2>&1 || die_pack "нет stat"

# Ложные зелёные от протекающего окружения: субъект обязан вычислять
# стартовую зону сам — унаследованное не засчитывается (055-прецедент).
unset HARNESS_SESSION_HOME HARNESS_SCRATCH METERING_PROJECT METERING_ROLE

root_hash8() { printf '%s' "$(cd "$1" && pwd -P)" | sha256sum | cut -c1-8; }

# ── строители toy-мира (полный профиль 054/055 — живой резолвер HEAD) ────────
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
}
LAYER="$WORK/layer-p1"; layer_make "$LAYER" p1
R1="$WORK/repo-p1"; repo_make "$R1" r1
# N1 (вердикт 058-v2, исполнение арбитража 058/N1 — РЕШЕНИЕ 773938b п.2):
# второй конформный вход — слой со СЛУЧАЙНЫМ projectId из ПОЛНОЙ грамматики
# поля (workshop:665 — ^[a-z0-9][a-z0-9_-]*$, единый источник) БЕЗ какого-либо
# фиксированного литерала: первый символ равномерно из [a-z0-9], остальные
# равномерно из [a-z0-9_-], длина равномерно 1..16; p1 перегенерируется;
# своё toy-репо. Честная клетка к15 судит на нём C1/PSTATE/A1 — И-1 применим
# к любому projectId допустимой грамматики: мутант с любым зашитым
# ЛИТЕРАЛОМ/набором id краснеет; предикат, подогнанный под распределение
# выборки, — именованный остаток, закрывается чтением исходника (арбитраж
# 058/N1). Новый id КАЖДЫЙ прогон (инвариантность к значениям —
# Демаркация 058). Fail-closed самопроверка генератора (п.2.2): результат
# сверяется ТЕМ ЖЕ regex и неравенством p1; несоответствие — die_pack
# (ОТКАЗ батареи), а не красная клетка: красная к15 всегда означает субъект,
# не генератор.
PID_AL_FIRST='abcdefghijklmnopqrstuvwxyz0123456789' # класс первого символа: [a-z0-9]
PID_AL_REST="${PID_AL_FIRST}_-"                      # класс остальных: [a-z0-9_-]
pid_pick() { # $1=алфавит → равномерный символ (rejection-выборка: без modulo-смещения)
  local n="${#1}" m r i
  m=$((32768 - 32768 % n))
  while :; do
    r=$RANDOM
    if [ "$r" -lt "$m" ]; then i=$((r % n)); printf '%s' "${1:i:1}"; return; fi
  done
}
pid_gen() { # projectId из полной грамматики: длина равномерно 1..16 (32768 кратно 16)
  local len i r
  len=$((RANDOM % 16 + 1))
  r="$(pid_pick "$PID_AL_FIRST")"
  for ((i = 2; i <= len; i++)); do r+="$(pid_pick "$PID_AL_REST")"; done
  printf '%s' "$r"
}
PID_RND=p1
while [ "$PID_RND" = p1 ]; do PID_RND="$(pid_gen)"; done # p1 перегенерируется (п.2.1)
printf '%s' "$PID_RND" | grep -Eq '^[a-z0-9][a-z0-9_-]*$' \
  || die_pack 'генератор projectId вне грамматики ^[a-z0-9][a-z0-9_-]*$: '"$PID_RND"
LAYER2="$WORK/layer-rnd"; layer_make "$LAYER2" "$PID_RND"
R2="$WORK/repo-rnd"; repo_make "$R2" r2

# ── СТАБ-OMP: субъект живого режима (к10 честной клетки) ─────────────────────
# Пишет факт СВОЕГО окружения и маркер в $HOME/.omp/.../agent.db СВОЕЙ сессии.
SHIMDIR="$WORK/shimbin"; mkdir -p "$SHIMDIR"
cat > "$SHIMDIR/omp" <<'SHIM'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then printf 'omp/v10\n'; exit 0; fi
printf 'pid=%s\n' "$$" > "$SHIM_OUT"
env | LC_ALL=C sort > "$SHIM_ENV"
mkdir -p "$HOME/.omp/profiles/dev/agent" 2>/dev/null || true
printf 'livesubj-058\n' >> "$HOME/.omp/profiles/dev/agent/agent.db" 2>/dev/null || true
exit 0
SHIM
chmod +x "$SHIMDIR/omp"

# ── БЕЗОПАСНЫЙ omp-shim ДЛЯ DEV-ВХОДА (к12, F2): не пишет НИЧЕГО — ни agent.db,
# ни фактов; дев-ветвь судится по выводу лаунчера и отсутствию agent.db под
# базой. Отделен от SHIMDIR: тот пишет маркер в agent.db СВОЕЙ сессии (к10) и
# в дев-зоне создал бы agent.db сам.
DEVSHIMDIR="$WORK/devshim"; mkdir -p "$DEVSHIMDIR"
printf '#!/usr/bin/env bash\nexit 0\n' > "$DEVSHIMDIR/omp"
chmod +x "$DEVSHIMDIR/omp"

# ── ОБМАННЫЙ СТАБ лаунчера 058: только шаг шаринга; обманывает ровно одной ───
# ручкой STUB_*; без ручек честен на своих клетках (c1..c9). Формула дев-зоны
# стартовая — от корня САМОГО стаба (тот же класс формулы, что workshop:75-99;
# клетка строит toy-зону по hash8 каталога стаба).
cat > "$WORK/stub-workshop" <<'STUB'
#!/usr/bin/env bash
set -uo pipefail
probe=0; repo=""
while [ $# -gt 0 ]; do case "$1" in
  --probe) probe=1 ;;
  *) repo="$1" ;;
esac; shift; done
pid_id="$(jq -r '.projectId' "${HARNESS_PROJECT_LAYER_ROOT:?}/registry/harness-project.json")"
base="${XDG_STATE_HOME:?нет XDG_STATE_HOME}"
SROOT="$(cd "$(dirname "$0")" && pwd -P)"
ZONE="$base/dev-harness-sessions/$(printf '%s' "$SROOT" | sha256sum | cut -c1-8)/zones/dev"
DEVDB="$ZONE/.omp/profiles/dev/agent/agent.db"
PSTATE="$base/dev-harness-projects/$pid_id"
PROJDB="$PSTATE/home/.omp/profiles/dev/agent/agent.db"
a1() { [ -z "${STUB_SILENT:-}" ] && printf 'AGENTDB: %s\n' "$1"; }
a2() { [ -z "${STUB_SILENT:-}" ] && printf 'AGENTDB: изолирована\n'; }
# s8 «probe без шага»: probe возвращается ДО шага (Граница-4 нарушена).
if [ "$probe" -eq 1 ] && [ -n "${STUB_NO_PROBE_STEP:-}" ]; then
  exit 0
fi
if [ -L "$PROJDB" ]; then
  cur="$(readlink -- "$PROJDB" 2>/dev/null || true)"
  if [ "$cur" = "$DEVDB" ] && [ -e "$DEVDB" ]; then
    # L1: идемпотентно; s4 «пересоздаёт» ломает inode ссылки.
    if [ -n "${STUB_RECREATE:-}" ]; then rm -f -- "$PROJDB"; ln -s -- "$DEVDB" "$PROJDB"; fi
    a1 "$DEVDB"
  elif [ -e "$DEVDB" ]; then
    # L2: чинить цель; s5 «не чинит» оставляет старую.
    if [ -z "${STUB_NO_FIX:-}" ]; then ln -sfn -- "$DEVDB" "$PROJDB"; fi
    a1 "$DEVDB"
  elif [ -e "$cur" ]; then
    # L3a: работающая ссылка на чужую живую цель, DEVDB нет — не трогать;
    # s7 «сносит любую ссылку» удаляет и печатает A2 (ОБХОД 058-v1).
    if [ -n "${STUB_RM_LINK:-}" ]; then rm -f -- "$PROJDB"; a2; else a1 "$cur"; fi
  else
    # L3b: dangling, DEVDB нет — rm, проект получает свою пустую.
    rm -f -- "$PROJDB"; a2
  fi
elif [ -e "$PROJDB" ]; then
  if [ -f "$PROJDB" ] && [ ! -s "$PROJDB" ]; then
    # R0: пустой регулярный замещается ссылкой; без DEVDB замещение
    # невозможно — не трогать, A2 (контракт И-1, примечание к R0).
    if [ -e "$DEVDB" ]; then
      rm -f -- "$PROJDB"; mkdir -p -- "$(dirname -- "$PROJDB")"; ln -s -- "$DEVDB" "$PROJDB"
      a1 "$DEVDB"
    else
      a2
    fi
  else
    # R1: непустой файл/каталог не трогаем; s6 «затирает» подменяет файл.
    if [ -n "${STUB_CLOBBER:-}" ]; then
      rm -f -- "$PROJDB"; mkdir -p -- "$(dirname -- "$PROJDB")"; ln -s -- "$DEVDB" "$PROJDB"
      a1 "$DEVDB"
    else
      printf 'workshop ПРЕДУПРЕЖДЕНИЕ: agent.db проекта — не симлинк, шаринг не активен (W8): %s — перенеси файл и перезапусти\n' "$PROJDB" >&2
      a2
    fi
  fi
else
  # C1/C2: s1 «всегда создаёт» материализует ссылку и при отсутствующем
  # DEVDB; s2 «копия» копирует файлом; s3 «шарит каталог» подменяет файл
  # ссылкой на каталог agent/.
  if [ -e "$DEVDB" ] || [ -n "${STUB_ALWAYS_CREATE:-}" ]; then
    if [ -n "${STUB_SHARE_DIR:-}" ]; then
      mkdir -p -- "$(dirname "$(dirname -- "$PROJDB")")"
      ln -s -- "$(dirname -- "$DEVDB")" "$(dirname -- "$PROJDB")"
    else
      mkdir -p -- "$(dirname -- "$PROJDB")"
      if [ -n "${STUB_COPY:-}" ]; then cp -- "$DEVDB" "$PROJDB"; else ln -s -- "$DEVDB" "$PROJDB"; fi
    fi
    a1 "$DEVDB"
  else
    a2
  fi
fi
exit 0
STUB
chmod +x "$WORK/stub-workshop"

# ── оракул в ПАМЯТИ (правило 8): ожидания строятся ДО вызова субъекта ────────
# Честные прогоны: дев-зона от hash8 КОРНЯ WORKSHOP (формула 028 потребляется
# построением toy-мира, не переизобретается в проверке).
devdb_of() { printf '%s/dev-harness-sessions/%s/zones/dev/.omp/profiles/dev/agent/agent.db' "$1" "$(root_hash8 "$ROOT")"; }
# Стаб-прогоны: дев-зона от hash8 каталога самого стаба.
stub_devdb_of() { printf '%s/dev-harness-sessions/%s/zones/dev/.omp/profiles/dev/agent/agent.db' "$1" "$(root_hash8 "$WORK")"; }
mk_devdb() { # $1=база → создаёт живой маркерный DEVDB, печатает путь
  local d; d="$(devdb_of "$1")"
  mkdir -p "$(dirname -- "$d")"
  printf 'devmark-058\n' > "$d"
  printf '%s' "$d"
}
probe_run() { # $1=база; probe живого workshop, rc наружу
  env XDG_STATE_HOME="$1" HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$WORKSHOP" --probe "$R1"
}
probe_run2() { # $1=база; probe живого workshop со слоем случайного projectId (к15, N1)
  env XDG_STATE_HOME="$1" HARNESS_PROJECT_LAYER_ROOT="$LAYER2" bash "$WORKSHOP" --probe "$R2"
}
live_run() { # $1=база дампа $2=база состояния; живой workshop со стаб-omp
  env PATH="$SHIMDIR:$PATH" XDG_STATE_HOME="$2" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key METERING_PROXY_TOKEN=toy-token \
    SHIM_ENV="$1.env" SHIM_OUT="$1.pid" bash "$WORKSHOP" "$R1"
}

# ── СТАБ-ПАК: клетки c1..c9, каждая ловит СВОЙ стаб; счёт напечатан ──────────
stub_probe() { # $1=база $2=выходной файл; стаб с ручками из окружения
  env XDG_STATE_HOME="$1" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    bash "$WORK/stub-workshop" --probe "$R1" > "$2" 2>&1
}
stub_projdb() { printf '%s/dev-harness-projects/p1/home/.omp/profiles/dev/agent/agent.db' "$1"; }
stub_home() { printf '%s/dev-harness-projects/p1/home' "$1"; }
stub_mk_devdb() { # живой маркерный DEVDB для стаб-прогона на базе $1
  local d; d="$(stub_devdb_of "$1")"
  mkdir -p "$(dirname -- "$d")"
  printf 'devmark-058\n' > "$d"
  printf '%s' "$d"
}

check_c1() { # s2 «копия»: PROJDB — не ссылка
  local b="$WORK/c1"; rm -rf "$b"; mkdir -p "$b"
  local d o; d="$(stub_mk_devdb "$b")"; o="$WORK/c1.out"
  STUB_COPY=1 stub_probe "$b" "$o"
  [ -L "$(stub_projdb "$b")" ] && return 1
  return 0
}
diff_c1() {
  local b="$WORK/c1d"; rm -rf "$b"; mkdir -p "$b"
  local d o p; d="$(stub_mk_devdb "$b")"; o="$WORK/c1d.out"
  stub_probe "$b" "$o"
  p="$(stub_projdb "$b")"
  [ -L "$p" ] && [ "$(readlink -- "$p")" = "$d" ] && grep -Fxq "AGENTDB: $d" "$o"
}
check_c2() { # s1 «всегда создаёт»: C2 — ссылка создана на отсутствующий DEVDB
  local b="$WORK/c2"; rm -rf "$b"; mkdir -p "$b"
  local o p; o="$WORK/c2.out"; p="$(stub_projdb "$b")"
  STUB_ALWAYS_CREATE=1 stub_probe "$b" "$o"
  # -L, не -e: dangling-ссылка (цель отсутствует) для -e невидима.
  { [ ! -e "$p" ] && [ ! -L "$p" ]; } && return 1
  return 0
}
diff_c2() {
  local b="$WORK/c2d"; rm -rf "$b"; mkdir -p "$b"
  local o p; o="$WORK/c2d.out"; p="$(stub_projdb "$b")"
  stub_probe "$b" "$o"
  [ ! -e "$p" ] && [ ! -L "$p" ] && [ ! -e "$(dirname -- "$p")" ] \
    && grep -Fxq 'AGENTDB: изолирована' "$o"
}
check_c3() { # s3 «шарит каталог»: PROJDB — не симлинк (ссылка — каталог agent/)
  local b="$WORK/c3"; rm -rf "$b"; mkdir -p "$b"
  local d o; d="$(stub_mk_devdb "$b")"; printf 'side-agent' > "$(dirname -- "$d")/side-agent.dat"
  o="$WORK/c3.out"
  STUB_SHARE_DIR=1 stub_probe "$b" "$o"
  [ -L "$(stub_projdb "$b")" ] && return 1
  return 0
}
diff_c3() {
  local b="$WORK/c3d"; rm -rf "$b"; mkdir -p "$b"
  local d o p home n; d="$(stub_mk_devdb "$b")"; printf 'side-agent' > "$(dirname -- "$d")/side-agent.dat"
  o="$WORK/c3d.out"
  stub_probe "$b" "$o"
  p="$(stub_projdb "$b")"; home="$(stub_home "$b")"
  n="$(find "$home" -type l 2>/dev/null | wc -l)"
  [ "$n" -eq 1 ] && [ -L "$p" ] \
    && ! find "$home" -name side-agent.dat -print -quit 2>/dev/null | grep -q .
}
check_c4() { # s4 «пересоздаёт»: readlink валидной ссылки заменён на каноническую цель
  local b="$WORK/c4"; rm -rf "$b"; mkdir -p "$b"
  local d o p d_alt; d="$(stub_mk_devdb "$b")"; o="$WORK/c4.out"; p="$(stub_projdb "$b")"
  d_alt="$(dirname -- "$d")/./$(basename -- "$d")"
  mkdir -p "$(dirname -- "$p")"; ln -s -- "$d_alt" "$p"
  STUB_RECREATE=1 stub_probe "$b" "$o"
  # стаб делает rm+ln с канонической $DEVDB==d → readlink==d (≠d_alt) → rc 0 (пойман);
  # честный L1 не трогает ссылку → readlink остаётся d_alt → rc 1 (не пойман).
  [ "$(readlink -- "$p" 2>/dev/null)" = "$d" ]
}
diff_c4() {
  local b="$WORK/c4d"; rm -rf "$b"; mkdir -p "$b"
  local d o p i1 i2; d="$(stub_mk_devdb "$b")"; o="$WORK/c4d.out"; p="$(stub_projdb "$b")"
  mkdir -p "$(dirname -- "$p")"; ln -s -- "$d" "$p"; i1="$(stat -c %i -- "$p")"
  stub_probe "$b" "$o"
  i2="$(stat -c %i -- "$p" 2>/dev/null || printf x)"
  [ "$(readlink -- "$p")" = "$d" ] && [ "$i1" = "$i2" ] && grep -Fxq "AGENTDB: $d" "$o"
}
check_c5() { # s5 «не чинит цель»: L2 — readlink остался старым
  local b="$WORK/c5"; rm -rf "$b"; mkdir -p "$b"
  local d o p old; d="$(stub_mk_devdb "$b")"; o="$WORK/c5.out"; p="$(stub_projdb "$b")"
  old="$b/old-zone/agent.db"; mkdir -p "$(dirname -- "$old")"; printf 'old' > "$old"
  mkdir -p "$(dirname -- "$p")"; ln -s -- "$old" "$p"
  STUB_NO_FIX=1 stub_probe "$b" "$o"
  [ "$(readlink -- "$p")" = "$d" ] && return 1
  return 0
}
diff_c5() {
  local b="$WORK/c5d"; rm -rf "$b"; mkdir -p "$b"
  local d o p old; d="$(stub_mk_devdb "$b")"; o="$WORK/c5d.out"; p="$(stub_projdb "$b")"
  old="$b/old-zone/agent.db"; mkdir -p "$(dirname -- "$old")"; printf 'old' > "$old"
  mkdir -p "$(dirname -- "$p")"; ln -s -- "$old" "$p"
  stub_probe "$b" "$o"
  local r=0
  { [ "$(readlink -- "$p")" = "$d" ] && grep -Fxq "AGENTDB: $d" "$o"; } || r=1
  # отдельный вход: dangling-ссылка при живом DEVDB — тот же исход (L2)
  local b2="$WORK/c5e"; rm -rf "$b2"; mkdir -p "$b2"
  local d2 o2 p2; d2="$(stub_mk_devdb "$b2")"; o2="$WORK/c5e.out"; p2="$(stub_projdb "$b2")"
  mkdir -p "$(dirname -- "$p2")"; ln -s -- "$b2/nope.db" "$p2"
  stub_probe "$b2" "$o2"
  { [ "$(readlink -- "$p2")" = "$d2" ] && grep -Fxq "AGENTDB: $d2" "$o2"; } || r=1
  [ "$r" -eq 0 ]
}
check_c6() { # s6 «затирает регулярный»: непустой PROJDB заменён
  local b="$WORK/c6"; rm -rf "$b"; mkdir -p "$b"
  local d o p; d="$(stub_mk_devdb "$b")"; o="$WORK/c6.out"; p="$(stub_projdb "$b")"
  mkdir -p "$(dirname -- "$p")"; printf 'own-own-own' > "$p"
  STUB_CLOBBER=1 stub_probe "$b" "$o"
  { [ -f "$p" ] && [ ! -L "$p" ] && [ "$(cat -- "$p")" = 'own-own-own' ]; } && return 1
  return 0
}
diff_c6() {
  local b="$WORK/c6d"; rm -rf "$b"; mkdir -p "$b"
  local d o p; d="$(stub_mk_devdb "$b")"; o="$WORK/c6d.out"; p="$(stub_projdb "$b")"
  mkdir -p "$(dirname -- "$p")"; printf 'own-own-own' > "$p"
  stub_probe "$b" "$o"
  [ -f "$p" ] && [ ! -L "$p" ] && [ "$(cat -- "$p")" = 'own-own-own' ] \
    && grep -Fq "workshop ПРЕДУПРЕЖДЕНИЕ: agent.db проекта — не симлинк, шаринг не активен (W8): $p — перенеси файл и перезапусти" "$o" \
    && grep -Fxq 'AGENTDB: изолирована' "$o"
}
check_c7() { # s7 «сносит любую ссылку»: L3a — работающая ссылка удалена
  local b="$WORK/c7"; rm -rf "$b"; mkdir -p "$b"
  local o p other; o="$WORK/c7.out"; p="$(stub_projdb "$b")"
  other="$b/other-zone/agent.db"; mkdir -p "$(dirname -- "$other")"; printf 'other' > "$other"
  mkdir -p "$(dirname -- "$p")"; ln -s -- "$other" "$p"
  STUB_RM_LINK=1 stub_probe "$b" "$o"
  { [ -L "$p" ] && [ "$(readlink -- "$p")" = "$other" ] && [ -e "$other" ]; } && return 1
  return 0
}
diff_c7() {
  local b="$WORK/c7d"; rm -rf "$b"; mkdir -p "$b"
  local o p other; o="$WORK/c7d.out"; p="$(stub_projdb "$b")"
  other="$b/other-zone/agent.db"; mkdir -p "$(dirname -- "$other")"; printf 'other' > "$other"
  mkdir -p "$(dirname -- "$p")"; ln -s -- "$other" "$p"
  stub_probe "$b" "$o"
  [ -L "$p" ] && [ "$(readlink -- "$p")" = "$other" ] && [ -e "$other" ] \
    && grep -Fxq "AGENTDB: $other" "$o"
}
check_c8() { # s8 «probe без шага»: probe не материализовал ссылку
  local b="$WORK/c8"; rm -rf "$b"; mkdir -p "$b"
  local d o; d="$(stub_mk_devdb "$b")"; o="$WORK/c8.out"
  STUB_NO_PROBE_STEP=1 stub_probe "$b" "$o"
  { [ -L "$(stub_projdb "$b")" ] && grep -Fq 'AGENTDB:' "$o"; } && return 1
  return 0
}
diff_c8() {
  local b="$WORK/c8d"; rm -rf "$b"; mkdir -p "$b"
  local d o; d="$(stub_mk_devdb "$b")"; o="$WORK/c8d.out"
  stub_probe "$b" "$o"
  [ -L "$(stub_projdb "$b")" ] && grep -Fxq "AGENTDB: $d" "$o"
}
check_c9() { # s9 «молчит»: строки AGENTDB нет
  local b="$WORK/c9"; rm -rf "$b"; mkdir -p "$b"
  local d o; d="$(stub_mk_devdb "$b")"; o="$WORK/c9.out"
  STUB_SILENT=1 stub_probe "$b" "$o"
  grep -Fq 'AGENTDB:' "$o" && return 1
  return 0
}
diff_c9() {
  local b="$WORK/c9d"; rm -rf "$b"; mkdir -p "$b"
  local d o; d="$(stub_mk_devdb "$b")"; o="$WORK/c9d.out"
  stub_probe "$b" "$o"
  grep -Fxq "AGENTDB: $d" "$o"
}

CAUGHT=0; SEEN=0; DIFF=0; DIFFSEEN=0
for n in c1 c2 c3 c4 c5 c6 c7 c8 c9; do
  SEEN=$((SEEN+1))
  if "check_$n"; then CAUGHT=$((CAUGHT+1)); else printf '058-батарея: клетка %s НЕ поймала свой стаб\n' "$n" >&2; fi
  DIFFSEEN=$((DIFFSEEN+1))
  if "diff_$n"; then DIFF=$((DIFF+1)); else printf '058-батарея: диффпроба %s — стаб без ручки упал\n' "$n" >&2; fi
done
[ "$SEEN" -eq 9 ] || die_pack "счёт стаб-клеток ≠ 9: $SEEN (пустая/лишняя выборка — красная)"
[ "$CAUGHT" -eq 9 ] || { printf 'стаб-пак: поймано %s из %s\n' "$CAUGHT" "$SEEN" >&2; exit 1; }
[ "$DIFF" -eq 9 ] || { printf 'диффпроба: прошли %s из %s\n' "$DIFF" "$DIFFSEEN" >&2; exit 1; }
printf 'стаб-пак: 9/9 поймано, диффпроба 9/9 — различимость жива (Н-39)\n'

# ── г0: предмет отсутствует — FAIL-FAST до честной части (054/055-прецедент) ─
if ! grep -qF 'AGENTDB:' "$WORKSHOP" 2>/dev/null; then
  printf 'ОТКАЗ: предмет отсутствует: %s (шаг шаринга agent.db — контракт 058)\n' "$WORKSHOP" >&2
  exit 1
fi

# ── ЧЕСТНАЯ ЧАСТЬ (клетки к1..к11, к13..к15; к12 исполняема — F2 вердикта) ──
HONEST=0; HSEEN=0
hcell() { local n="$1"; shift; HSEEN=$((HSEEN+1)); "$@" && HONEST=$((HONEST+1)) || printf '058-батарея: честная клетка %s красная\n' "$n" >&2; }
projdb_of() { printf '%s/dev-harness-projects/p1/home/.omp/profiles/dev/agent/agent.db' "$1"; }
home_of() { printf '%s/dev-harness-projects/p1/home' "$1"; }

k1() { # И-1 C1 + И-4а: ссылка возникает, маркер дев-базы читается, баннер A1
  local b="$WORK/k1"; rm -rf "$b"; mkdir -p "$b"
  local d out rc=0 p; d="$(mk_devdb "$b")"; p="$(projdb_of "$b")"
  out="$(probe_run "$b" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] \
    && printf '%s\n' "$out" | grep -Fxq "STATE: $b/dev-harness-projects/p1" \
    && [ -L "$p" ] && [ "$(readlink -- "$p")" = "$d" ] \
    && grep -Fq 'devmark-058' "$p" \
    && printf '%s\n' "$out" | grep -Fxq "AGENTDB: $d"
}
k2() { # И-1 C2: DEVDB нет — ни ссылки, ни каталогов шага, баннер A2
  local b="$WORK/k2"; rm -rf "$b"; mkdir -p "$b"
  local out rc=0 p; p="$(projdb_of "$b")"
  out="$(probe_run "$b" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] \
    && [ ! -e "$p" ] && [ ! -L "$p" ] \
    && printf '%s\n' "$out" | grep -Fxq 'AGENTDB: изолирована'
}
k3() { # И-2: ровно одна ссылка в дереве PSTATE/home, её путь PROJDB; маркеры дев-зоны не видны
  local b="$WORK/k3"; rm -rf "$b"; mkdir -p "$b"
  local d p home zdir n; d="$(mk_devdb "$b")"; p="$(projdb_of "$b")"
  printf 'side-agent' > "$(dirname -- "$d")/side-agent.dat"
  zdir="$b/dev-harness-sessions/$(root_hash8 "$ROOT")/zones/dev"
  printf 'side-zone' > "$zdir/side-zone.dat"
  probe_run "$b" >/dev/null 2>&1
  home="$(home_of "$b")"
  n="$(find "$home" -type l 2>/dev/null | wc -l)"
  [ "$n" -eq 1 ] && [ -L "$p" ] \
    && ! find "$home" \( -name side-agent.dat -o -name side-zone.dat \) -print -quit 2>/dev/null | grep -q .
}
k4() { # И-3 L1: повторный probe не пересоздает валидную ссылку
  local b="$WORK/k4"; rm -rf "$b"; mkdir -p "$b"
  local d out rc=0 p i1 i2; d="$(mk_devdb "$b")"; p="$(projdb_of "$b")"
  probe_run "$b" >/dev/null 2>&1
  i1="$(stat -c %i -- "$p" 2>/dev/null || printf x)"
  out="$(probe_run "$b" 2>&1)"; rc=$?
  i2="$(stat -c %i -- "$p" 2>/dev/null || printf x)"
  [ "$rc" -eq 0 ] && [ "$(readlink -- "$p")" = "$d" ] && [ "$i1" = "$i2" ] \
    && printf '%s\n' "$out" | grep -Fxq "AGENTDB: $d"
}
k5() { # И-3 L2: устаревшая и dangling ссылки чинятся на текущий DEVDB
  local b="$WORK/k5"; rm -rf "$b"; mkdir -p "$b"
  local d out rc=0 p old r=0; d="$(mk_devdb "$b")"; p="$(projdb_of "$b")"
  old="$b/old-zone/agent.db"; mkdir -p "$(dirname -- "$old")"; printf 'old' > "$old"
  mkdir -p "$(dirname -- "$p")"; ln -s -- "$old" "$p"
  out="$(probe_run "$b" 2>&1)"; rc=$?
  { [ "$rc" -eq 0 ] && [ "$(readlink -- "$p")" = "$d" ] && printf '%s\n' "$out" | grep -Fxq "AGENTDB: $d"; } || r=1
  local b2="$WORK/k5b"; rm -rf "$b2"; mkdir -p "$b2"
  local d2 out2 rc2=0 p2; d2="$(mk_devdb "$b2")"; p2="$(projdb_of "$b2")"
  mkdir -p "$(dirname -- "$p2")"; ln -s -- "$b2/nope.db" "$p2"
  out2="$(probe_run "$b2" 2>&1)"; rc2=$?
  { [ "$rc2" -eq 0 ] && [ "$(readlink -- "$p2")" = "$d2" ] && printf '%s\n' "$out2" | grep -Fxq "AGENTDB: $d2"; } || r=1
  [ "$r" -eq 0 ]
}
k6() { # И-1 L3b: dangling, DEVDB нет — путь свободен, A2
  local b="$WORK/k6"; rm -rf "$b"; mkdir -p "$b"
  local out rc=0 p; p="$(projdb_of "$b")"
  mkdir -p "$(dirname -- "$p")"; ln -s -- "$b/nope.db" "$p"
  out="$(probe_run "$b" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] && [ ! -e "$p" ] && [ ! -L "$p" ] \
    && printf '%s\n' "$out" | grep -Fxq 'AGENTDB: изолирована'
}
k7() { # И-1 R1/W8: непустой файл не тронут, полная W8, A2
  local b="$WORK/k7"; rm -rf "$b"; mkdir -p "$b"
  local d out rc=0 p i1 i2; d="$(mk_devdb "$b")"; p="$(projdb_of "$b")"
  mkdir -p "$(dirname -- "$p")"; printf 'own-own-own' > "$p"
  i1="$(stat -c %i -- "$p")"
  out="$(probe_run "$b" 2>&1)"; rc=$?
  i2="$(stat -c %i -- "$p" 2>/dev/null || printf x)"
  [ "$rc" -eq 0 ] && [ -f "$p" ] && [ ! -L "$p" ] && [ "$(cat -- "$p")" = 'own-own-own' ] \
    && [ "$i1" = "$i2" ] \
    && printf '%s\n' "$out" | grep -Fq "workshop ПРЕДУПРЕЖДЕНИЕ: agent.db проекта — не симлинк, шаринг не активен (W8): $p — перенеси файл и перезапусти" \
    && printf '%s\n' "$out" | grep -Fxq 'AGENTDB: изолирована'
}
k8() { # И-1 R0: пустой файл замещён ссылкой
  local b="$WORK/k8"; rm -rf "$b"; mkdir -p "$b"
  local d out rc=0 p; d="$(mk_devdb "$b")"; p="$(projdb_of "$b")"
  mkdir -p "$(dirname -- "$p")"; : > "$p"
  out="$(probe_run "$b" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] && [ -L "$p" ] && [ "$(readlink -- "$p")" = "$d" ] \
    && printf '%s\n' "$out" | grep -Fxq "AGENTDB: $d"
}
k9() { # И-4б: запись в PROJDB видна в DEVDB; inode цели совпадает
  local b="$WORK/k9"; rm -rf "$b"; mkdir -p "$b"
  local d p; d="$(mk_devdb "$b")"; p="$(projdb_of "$b")"
  probe_run "$b" >/dev/null 2>&1
  printf 'projmark-058\n' >> "$p"
  grep -Fq 'projmark-058' "$d" \
    && [ "$(stat -Lc %i -- "$p")" = "$(stat -c %i -- "$d")" ]
}
k10() { # И-4в/И-5: живой субъект пишет через ссылку в DEVDB; HOME сессии — PSTATE/home
  local b="$WORK/k10"; rm -rf "$b"; mkdir -p "$b"
  local d rc=0; d="$(mk_devdb "$b")"
  live_run "$WORK/k10" "$b" >/dev/null 2>&1 || rc=$?
  [ "$rc" -eq 0 ] || return 1
  grep -Fq 'livesubj-058' "$d" || return 1
  [ -s "$WORK/k10.env" ] || return 1
  grep -Fxq "HOME=$(home_of "$b")" "$WORK/k10.env"
}
k11() { # И-5, регресс: батареи 054/055 зелёные на дереве с дельтой 058
  local r1=0 r2=0
  env -u HARNESS_SESSION_HOME -u HARNESS_SCRATCH -u XDG_STATE_HOME \
    -u METERING_PROJECT -u METERING_ROLE bash "$ROOT/fixtures/_krasnye_054.sh" >/dev/null 2>&1 || r1=$?
  env -u HARNESS_SESSION_HOME -u HARNESS_SCRATCH -u XDG_STATE_HOME \
    -u METERING_PROJECT -u METERING_ROLE bash "$ROOT/fixtures/_krasnye_055.sh" >/dev/null 2>&1 || r2=$?
  [ "$r1" -eq 0 ] && [ "$r2" -eq 0 ]
}

k12() { # И-6 (F2 вердикта 058-v1: к12 исполняема): дев-вход БЕЗ проекта,
        # безопасный omp-shim в PATH. Ожидания в ПАМЯТИ до вызова: rc 0; в
        # выводе НЕТ ни 'AGENTDB:', ни фразы W8; маркер живого DEVDB дев-зоны
        # не изменён; под базой НЕ возникло ни одного agent.db помимо DEVDB —
        # шаг живёт только в проектной ветви (Граница-6). Печать AGENTDB: в
        # дев-ветви (мутант F2) краснеет выводом, не статикой исходника.
  local b="$WORK/k12"; rm -rf "$b"; mkdir -p "$b"
  local d out rc=0
  d="$(mk_devdb "$b")"
  out="$(env -u HARNESS_PROJECT_LAYER_ROOT PATH="$DEVSHIMDIR:$PATH" \
    XDG_STATE_HOME="$b" ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key \
    METERING_PROXY_TOKEN=toy-token METERING_PROXY_URL=http://toy.invalid:1 \
    bash "$WORKSHOP" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] \
    && ! printf '%s\n' "$out" | grep -Fq 'AGENTDB:' \
    && ! printf '%s\n' "$out" | grep -Fq 'не симлинк, шаринг не активен' \
    && [ "$(cat -- "$d" 2>/dev/null)" = 'devmark-058' ] \
    && ! find "$b" -name agent.db ! -path "$d" -print -quit 2>/dev/null | grep -q .
}
k13() { # И-1 L3a: работающая ссылка на чужую живую цель, DEVDB нет — не тронута, баннер фактического readlink
  local b="$WORK/k13"; rm -rf "$b"; mkdir -p "$b"
  local out rc=0 p other i1 i2; p="$(projdb_of "$b")"
  other="$b/other-zone/agent.db"; mkdir -p "$(dirname -- "$other")"; printf 'othermark' > "$other"
  mkdir -p "$(dirname -- "$p")"; ln -s -- "$other" "$p"
  i1="$(stat -c %i -- "$p")"
  out="$(probe_run "$b" 2>&1)"; rc=$?
  i2="$(stat -c %i -- "$p" 2>/dev/null || printf x)"
  [ "$rc" -eq 0 ] && [ -L "$p" ] && [ "$(readlink -- "$p")" = "$other" ] \
    && [ "$i1" = "$i2" ] && [ "$(cat -- "$other")" = 'othermark' ] \
    && printf '%s\n' "$out" | grep -Fxq "AGENTDB: $other"
}
k14() { # И-1 R0 без DEVDB: пустой файл не тронут, A2 (замещение невозможно)
  local b="$WORK/k14"; rm -rf "$b"; mkdir -p "$b"
  local out rc=0 p; p="$(projdb_of "$b")"
  mkdir -p "$(dirname -- "$p")"; : > "$p"
  out="$(probe_run "$b" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] && [ -f "$p" ] && [ ! -L "$p" ] && [ ! -s "$p" ] \
    && printf '%s\n' "$out" | grep -Fxq 'AGENTDB: изолирована'
}

k15() { # И-1 C1 для projectId ВНЕ зашитого набора (N1, арбитраж 058/N1): слой
        # со СЛУЧАЙНЫМ валидным projectId из ПОЛНОЙ грамматики поля ($PID_RND,
        # новый каждый прогон, без фиксированного литерала), живой маркерный
        # DEVDB, свой toy-репо R2; probe обязан создать ссылку PROJDB на DEVDB
        # (C1), PSTATE — .../dev-harness-projects/$PID_RND, баннер A1, маркер
        # читается через ссылку. Мутант с любым зашитым ЛИТЕРАЛОМ/набором id
        # («exec честного для известных, иначе поддельное A2 rc=0») здесь
        # красен: нет ни ссылки, ни STATE-строки. Предикат, подогнанный под
        # распределение выборки, — именованный остаток, закрывается чтением
        # исходника (арбитраж 058/N1 п.2.5: статическая проверка батареей
        # отклонена).
  local b="$WORK/k15"; rm -rf "$b"; mkdir -p "$b"
  local d out rc=0 p
  d="$(mk_devdb "$b")"; p="$b/dev-harness-projects/$PID_RND/home/.omp/profiles/dev/agent/agent.db"
  out="$(probe_run2 "$b" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] \
    && printf '%s\n' "$out" | grep -Fxq "STATE: $b/dev-harness-projects/$PID_RND" \
    && [ -L "$p" ] && [ "$(readlink -- "$p")" = "$d" ] \
    && grep -Fq 'devmark-058' "$p" \
    && printf '%s\n' "$out" | grep -Fxq "AGENTDB: $d"
}

k16() { # И-2/N2 (вердикт 058-v2): симлинк-родитель — $PSTATE/home ЗАРАНЕЕ
        # указывает на внешний каталог (вне PSTATE-корня); конформный C1-вход
        # (валидный projectId, живой маркерный DEVDB), единственная подмена —
        # родитель. Клетка судит ИНВАРИАНТ (frozen И-2), не фразу фикса:
        # запуск обязан ИМЕНОВАННО отказать (rc≠0 ∧ непустой вывод) ДО
        # материализации любого дочернего состояния сквозь ссылку — ни
        # agent.db, ни session-prompt, ни агентов; ничего не материализуется
        # по канонической цепочке вне PSTATE-корня (снимок дерева внешнего
        # каталога до == после). ЗЕЛЁНОЕ предъявление — на ОБЪЕДИНЕНИИ с
        # wip/058/implementer (фикс N2: fail-closed гард до первого mkdir);
        # на дереве без фикса клетка КРАСНАЯ по умыслу (N2 жив; живой прогон
        # 2026-09-30: rc=0, во внешнем каталоге материализуются
        # session-prompt-*.md, .omp/agent/agents/* и
        # .omp/profiles/dev/agent/agent.db).
  local b="$WORK/k16"; rm -rf "$b"; mkdir -p "$b"
  local d ext home before after out rc=0
  d="$(mk_devdb "$b")"
  ext="$b/vneshnij-katalog"; mkdir -p "$ext"
  home="$b/dev-harness-projects/p1/home"; mkdir -p "$(dirname -- "$home")"
  ln -s -- "$ext" "$home"
  before="$(find "$ext" -mindepth 1 | LC_ALL=C sort)"
  out="$(probe_run "$b" 2>&1)"; rc=$?
  after="$(find "$ext" -mindepth 1 | LC_ALL=C sort)"
  [ "$rc" -ne 0 ] && [ -n "$out" ] && [ "$before" = "$after" ]
}

hcell к1 k1
hcell к2 k2
hcell к3 k3
hcell к4 k4
hcell к5 k5
hcell к6 k6
hcell к7 k7
hcell к8 k8
hcell к9 k9
hcell к10 k10
hcell к11 k11
hcell к12 k12
hcell к13 k13
hcell к14 k14
hcell к15 k15
hcell к16 k16
printf 'к15: случайный projectId=%s из полной грамматики (без литерала) — зашитый ЛИТЕРАЛ/набор id краснеет; предикат по распределению — остаток, закрывается чтением исходника (арбитраж 058/N1)\n' "$PID_RND"
[ "$HSEEN" -eq 16 ] || die_pack "счёт честных клеток ≠ 16: $HSEEN (пустая/лишняя выборка — красная)"
[ "$HONEST" -eq "$HSEEN" ] || { printf 'честная часть: %s из %s\n' "$HONEST" "$HSEEN" >&2; exit 1; }
printf 'честная часть: 16/16 зелёная; предъявлений: стабы 9/9 + дифф 9/9 + честные 16/16\n'
exit 0
