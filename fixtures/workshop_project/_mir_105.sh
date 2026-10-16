#!/usr/bin/env bash
# _mir_105.sh — каркас мира батареи 105 «лаунчер передаёт политику установки в
# сессию проекта» (контракт 105; семья fixtures/workshop_project/, probe-only 034).
# Источится клетками red_*_105.sh и стаб-паком battery_stubs_105.sh; сам не
# исполняется.
#
# СУБЪЕКТ — файл лаунчера, заданный W105_SUBJECT (умолчание: <корень>/workshop;
# раннер `--model` подставляет model_105/workshop.sh). Субъект КОПИРУЕТСЯ в
# игрушечную УСТАНОВКУ ($INSTALL/workshop), и там его $HERE = $INSTALL:
# у установки своя .omp/extensions/ со СЛУЧАЙНЫМ числом (2..5) и случайными
# именами *.ts (инвариантность к значениям — стаб с зашитым списком реальной
# установки клетку не проходит), приманки .omp/extensions/notes.js и README.md
# (вне грамматики `*.ts`), копия .omp/config.yml мастерской (session_model
# читает modelRoles из неё), симлинки scripts/ roles/ config/ AGENTS.md
# .omp/agents на корень мастерской (резолвер/генератор ролей — живые HEAD).
#
# ОРАКУЛ — в памяти клетки ДО вызова субъекта (правило 8): список ожидаемых
# путей расширений EXPECT_EXT, путь политики EXPECT_CFG, множество имён ролей
# EXPECT_ROLES. Диск субъекта как истина не перечитывается.
#
# СТАБ-OMP (прецедент 060 к7/к8, 070): живой режим субъекта заканчивается
# `exec omp` (поиск по PATH); стаб пишет СВОЙ argv (по строке на элемент) в
# $SHIM_ARGV, своё окружение в $SHIM_ENV и дописывает строку `version`|`launch`
# в $SHIM_CALLS на КАЖДЫЙ вызов (включая `omp --version` сверки пина) —
# счётчик вызовов для И-4 («отказ ДО вызова omp» = файл пуст/отсутствует).
set -uo pipefail
M105_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="${W105_ROOT:-$(cd "$M105_DIR/../.." && pwd -P)}"
SUBJECT="${W105_SUBJECT:-$ROOT/workshop}"
CELL="${CELL:-105}"
die_pack() { printf '105 %s ОТКАЗ: мир сломан, не предмет: %s\n' "$CELL" "$*" >&2; exit 2; }
krasno()   { printf '105 %s КРАСНО: %s\n' "$CELL" "$*" >&2; return 1; }
command -v git >/dev/null 2>&1 || die_pack "нет git"
command -v jq >/dev/null 2>&1 || die_pack "нет jq"
command -v node >/dev/null 2>&1 || die_pack "нет node"
command -v sha256sum >/dev/null 2>&1 || die_pack "нет sha256sum"
[ -f "$SUBJECT" ] || die_pack "субъекта нет: $SUBJECT"
[ -f "$ROOT/.omp/config.yml" ] || die_pack "нет $ROOT/.omp/config.yml"
[ -d "$ROOT/roles" ] || die_pack "нет $ROOT/roles"

# Ложные зелёные от протекающего окружения (055/058/070-прецедент).
unset HARNESS_SESSION_HOME HARNESS_SCRATCH METERING_PROJECT METERING_ROLE
unset ODELIX_GITHUB_TOKEN HARNESS_GITHUB_MODE HARNESS_WORKFLOW_ROOT HARNESS_TOOLS_ROOT
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR

WORK="$(mktemp -d "${TMPDIR:-/tmp}/red105.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
rnd() { printf '%s' "${RANDOM}${RANDOM}${RANDOM}$$" | sha256sum | cut -c1-"${1:-8}"; }

# ── игрушечная УСТАНОВКА: субъект + случайные расширения + политика ──────────
INSTALL="$WORK/install"
EXT_N=$(( 2 + RANDOM % 4 ))          # 2..5 — ≠ 1 (у проекта ровно один evil.ts)
EXPECT_EXT=()                         # оракул И-1/И-5 (в памяти, до вызова субъекта)
mkdir -p "$INSTALL/.omp/extensions"
cp "$SUBJECT" "$INSTALL/workshop"
for d in scripts roles config AGENTS.md; do ln -s "$ROOT/$d" "$INSTALL/$d"; done
ln -s "$ROOT/.omp/agents" "$INSTALL/.omp/agents"
cp "$ROOT/.omp/config.yml" "$INSTALL/.omp/config.yml"
i=0
while [ "$i" -lt "$EXT_N" ]; do
  i=$((i+1))
  f="$INSTALL/.omp/extensions/ext_${i}_$(rnd 6).ts"
  printf '// toy extension %s\n' "$i" > "$f"
  EXPECT_EXT+=("$f")
done
printf '// приманка вне грамматики *.ts\n' > "$INSTALL/.omp/extensions/notes.js"
printf 'приманка\n' > "$INSTALL/.omp/extensions/README.md"
EXPECT_CFG="$INSTALL/.omp/config.yml"
EXPECT_ROLES="$(ls "$ROOT/roles" | LC_ALL=C sort)"
[ -n "$EXPECT_ROLES" ] || die_pack "roles/ пуст — оракул ролей пуст"
TOY_MODEL="toy/model-$(rnd 10)"       # литеральный id оверлея (случайный)
TOY_OVERLAY="$WORK/overlay-$(rnd 4).yml"
printf '# toy overlay 105\nmodelRoles:\n  default: "%s"\n' "$TOY_MODEL" > "$TOY_OVERLAY"

# ── toy-мир проекта (полный профиль 054/058 — живой резолвер HEAD; прецедент 070) ──
layer_make() { # $1=корень слоя $2=projectId
  mkdir -p "$1/registry"
  printf '{"schemaVersion":1,"version":"v10","projectId":"%s","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"cargo test","build":"cargo build","typecheck":"cargo check","lint":"cargo clippy"},"git":{"canonicalRemote":"git@host:p1.git"},"ci":{"workflow":".github/workflows/ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":[]}}}' "$2" > "$1/registry/harness-project.json"
}
repo_make() { # $1=корень репо $2=repoId — несёт СОБСТВЕННЫЙ .omp/extensions/evil.ts (негатив И-1)
  local r="$1"
  mkdir -p "$r/config" "$r/.github/workflows" "$r/.omp/extensions"
  git -C "$r" init -q
  git -C "$r" config receive.denyCurrentBranch refuse
  printf '{"schemaVersion":1,"repoId":"%s","language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"ci":{"workflow":".github/workflows/ci.yml"},"git":{"canonicalRemote":"git@host:r1.git"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}' "$2" > "$r/harness.project.json"
  printf '{"version":"v10"}\n' > "$r/config/harness_pin.json"
  printf 'METERING_PROXY_URL=http://toy.invalid:1\n' > "$r/.env"
  printf 'name: toy ci\n' > "$r/.github/workflows/ci.yml"
  printf '// расширение ПРОЕКТА — в argv лаунчера его быть не должно\n' > "$r/.omp/extensions/evil.ts"
}
LAYER="$WORK/layer-p1"; layer_make "$LAYER" p1
REPO="$WORK/repo-p1";   repo_make "$REPO" r1
EVIL="$REPO/.omp/extensions/evil.ts"

# ── стаб-omp: субъект живого режима ─────────────────────────────────────────
SHIMDIR="$WORK/shimbin"; mkdir -p "$SHIMDIR"
cat > "$SHIMDIR/omp" <<'SHIM'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then
  printf 'version\n' >> "${SHIM_CALLS:?нет SHIM_CALLS}"
  printf 'omp/v10\n'; exit 0
fi
printf 'launch\n' >> "${SHIM_CALLS:?нет SHIM_CALLS}"
printf '%s\n' "$@" > "${SHIM_ARGV:?нет SHIM_ARGV}"
env | LC_ALL=C sort > "${SHIM_ENV:?нет SHIM_ENV}"
exit 0
SHIM
chmod +x "$SHIMDIR/omp"

# ── прогоны субъекта (копии в установке) ────────────────────────────────────
# $1=имя прогона (файлы $WORK/<имя>.{out,err,argv,env,calls}); далее — аргументы
# лаунчера ПОСЛЕ каталога проекта (пусто — без флагов). HOME/XDG — свои на прогон.
_run() { # $1=имя $2=режим(live|probe) ...=хвост аргументов
  local n="$1" mode="$2"; shift 2
  local h="${RUN_HOME:-$WORK/home-$n}"; mkdir -p "$h"
  local pre=()
  [ "$mode" = probe ] && pre=(--probe)
  rm -f "$WORK/$n.calls" "$WORK/$n.argv" "$WORK/$n.env"
  RC=0
  env PATH="$SHIMDIR:$PATH" HOME="$h" XDG_STATE_HOME="$h.state" \
    HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
    ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key METERING_PROXY_TOKEN=toy-token \
    METERING_PROXY_URL=http://toy.invalid:1 \
    SHIM_CALLS="$WORK/$n.calls" SHIM_ARGV="$WORK/$n.argv" SHIM_ENV="$WORK/$n.env" \
    bash "$INSTALL/workshop" "${pre[@]}" "$REPO" "$@" > "$WORK/$n.out" 2> "$WORK/$n.err" || RC=$?
}
run_live()  { local n="$1"; shift; _run "$n" live "$@"; }   # PATH со стаб-omp; rc в $RC
run_probe() { local n="$1"; shift; _run "$n" probe "$@"; }  # тот же PATH — вызов omp из пробы виден в .calls
calls_n()  { if [ -f "$WORK/$1.calls" ]; then wc -l < "$WORK/$1.calls"; else printf '0\n'; fi; }
launch_n() { if [ -f "$WORK/$1.calls" ]; then grep -cx 'launch' "$WORK/$1.calls"; else printf '0\n'; fi; }
# значения флага $2 в argv прогона $1 (по строке на значение; флаг и значение — соседние строки)
argv_vals() {
  [ -f "$WORK/$1.argv" ] || return 0
  awk -v f="$2" 'prev==f {print} {prev=$0}' "$WORK/$1.argv"
}
argv_count() { # число вхождений токена $2 как САМОСТОЯТЕЛЬНОЙ строки argv
  if [ -f "$WORK/$1.argv" ]; then grep -cxF -- "$2" "$WORK/$1.argv"; else printf '0\n'; fi
}
argv_index_of_pair() { # номер строки первого вхождения пары «$2<NL>$3» (0 — нет)
  [ -f "$WORK/$1.argv" ] || { printf '0\n'; return 0; }
  awk -v f="$2" -v v="$3" 'prev==f && $0==v {print NR-1; exit} {prev=$0}' "$WORK/$1.argv" | grep . || printf '0\n'
}
out_vals() { sed -n "s/^$2: //p" "$WORK/$1.out"; }   # значения строк `^<ключ>: ` в stdout прогона $1
sorted() { LC_ALL=C sort; }
expect_ext_sorted() { printf '%s\n' "${EXPECT_EXT[@]}" | sorted; }
pokazat() { sed -n '1,12p' "$WORK/$1.err" >&2 || true; }   # диагностика красной клетки
