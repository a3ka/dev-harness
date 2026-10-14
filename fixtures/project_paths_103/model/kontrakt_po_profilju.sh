#!/usr/bin/env bash
# Честная модель 103 для трёх чтений make_task «контракт/план по workflowPaths»
# (грамматика предмета И-1а–И-1д/И-5; CLI — подмножество make_task.sh 095,
# лишние флаги принимаются и игнорируются). Эффективное значение
# workflowPaths — репо-слой, иначе defaults слоя проекта (семантика v()
# резолвера 054). Каждый путь workflowPaths.* канонизируется от корня репо и
# обязан лежать ВНУТРИ репо (`..`, абсолют, симлинк наружу → «ОТКАЗ:
# workflowPaths вне репо: <ключ>=<значение>»).
#   (д) черновик:  ТОЛЬКО <repo>/<contracts>/<NNN>-*.md; нет → «ОТКАЗ: черновик
#                  контракта не найден: <NNN>» (фраза 095 дословно);
#   (з) заморозка: тег frozen/contracts/<NNN>/* есть → ls-tree ТОЛЬКО по
#                  "<contracts>/" в блобе тега (корень тега — НЕ фолбэк); пусто
#                  → «ОТКАЗ: заморозка без контракта: <тег>» (095 дословно);
#   (б) бриф:      GOAL = <registry>/plan.tsv побайтово, WORK = по строке на
#                  каждый <contracts>/*.md («WORK: <NNN> :: <§Предмет>», 095).
# Вывод: секции CONTEXT/ZONES (task) либо GOAL/WORK (brief) как у 095.
set -uo pipefail
die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
REPO=""; CONTRACT=""; ROLE=""; KIND="task"
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:?}"; shift 2 ;;
    --contract) CONTRACT="${2:?}"; shift 2 ;;
    --role) ROLE="${2:?}"; shift 2 ;;
    --kind) KIND="${2:?}"; shift 2 ;;
    --task-file|--model-trace|--author-role) shift 2 ;;
    *) shift ;;
  esac
done
[ -d "$REPO" ] || die "репозитория нет: $REPO"
[ -f "$REPO/harness.project.json" ] || die "профиль репо не найден: harness.project.json"
REPO_ABS="$(cd "$REPO" && pwd -P)"
PL="$(jq -r '.projectLayer.profilePath // empty' "$REPO/harness.project.json")"
wp() {  # <ключ> — эффективное значение workflowPaths.<ключ>
  local v
  v="$(jq -r --arg k "$1" '.workflowPaths[$k] // empty' "$REPO/harness.project.json")"
  [ -n "$v" ] || v="$(jq -r --arg k "$1" '.defaults.workflowPaths[$k] // empty' "$REPO/$PL" 2>/dev/null)"
  printf '%s' "$v"
}
# источник путей контрактов/реестра — профиль, не harness-layout (маркеры стабов)
WP_C="$(wp contracts)" # t103-m1
WP_G="$(wp registry)" # t103-m10
[ -n "$WP_C" ] || die "профиль без workflowPaths.contracts"
[ -n "$WP_G" ] || die "профиль без workflowPaths.registry"
for k in contracts verdicts registry fixtures; do
  v="$(wp "$k")"
  canon="$(readlink -f -- "$REPO_ABS/$v" 2>/dev/null || true)"
  case "$v" in /*) canon="/вне" ;; esac
  case "$canon" in "$REPO_ABS"/*) ;; *) die "workflowPaths вне репо: $k=$v" ;; esac # t103-m2
done

if [ "$KIND" = "brief" ]; then
  [ "$ROLE" = "orchestrator" ] || die "брифинг только оркестратору"
  GOAL_SEC=""; WORK_SEC=""
  [ -f "$REPO/$WP_G/plan.tsv" ] && GOAL_SEC="$(cat "$REPO/$WP_G/plan.tsv")"
  for cf in $(LC_ALL=C ls "$REPO/$WP_C"/*.md 2>/dev/null | LC_ALL=C sort); do
    cnum="$(basename "$cf")"; cnum="${cnum%%-*}"
    csubj="$(awk '/^## Предмет/{f=1;next} /^## /{f=0} f&&NF{print;exit}' "$cf")"
    [ -n "$csubj" ] || csubj="legacy-без-§Предмет (вне plan.tsv)"
    WORK_SEC="${WORK_SEC}WORK: ${cnum} :: ${csubj}
"
  done
  if [ -n "$GOAL_SEC" ]; then printf '=== GOAL ===\n%s\n' "$GOAL_SEC"; fi
  if [ -n "$WORK_SEC" ]; then printf '=== WORK ===\n%s' "$WORK_SEC"; fi
  exit 0
fi

[ -n "$CONTRACT" ] || die "контракт не указан"
TAG="$(git -C "$REPO" tag -l "frozen/contracts/$CONTRACT/*" 2>/dev/null | LC_ALL=C sort -V | tail -n 1)"
if [ -n "$TAG" ]; then
  # заморозка: путь контракта ВНУТРИ блоба тега — профильный, корень тега не фолбэк
  FROZEN_DIR="$WP_C" # t103-m9
  CPATH="$(git -C "$REPO" ls-tree --name-only "$TAG" "$FROZEN_DIR/" | grep -E "^$FROZEN_DIR/${CONTRACT}-[^/]+\.md$" | head -n 1)"
  [ -n "$CPATH" ] || die "заморозка без контракта: $TAG"
  CBYTES="$(git -C "$REPO" show "$TAG:$CPATH" 2>&1)"
else
  CPATH="$(cd "$REPO" && ls "$WP_C"/${CONTRACT}-*.md 2>/dev/null | head -n 1)"
  [ -n "$CPATH" ] || die "черновик контракта не найден: $CONTRACT"
  CBYTES="$(cat "$REPO/$CPATH")"
fi
printf '=== CONTEXT ===\n'
printf '%s\n' "$CBYTES" | grep '^КОНТЕКСТ:'
printf '%s\n' "$CBYTES" | awk '/^## Существующее$/{f=1;print;next} /^## /{f=0} f{print}'
printf '=== ZONES ===\n'
printf '%s\n' "$CBYTES" | grep '^ЗОНА ' || true
exit 0
