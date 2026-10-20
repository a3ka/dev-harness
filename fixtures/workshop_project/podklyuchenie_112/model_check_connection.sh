#!/usr/bin/env bash
# МОДЕЛЬ-ЭТАЛОН scripts/check_project_connection.sh (контракт 112).
# Эталон шва для красной батареи red_podkljuchenie_112.sh --model: показывает,
# как выглядит честная проверка подключения. Реализацию в scripts/ пишет
# implementer по контракту; модель НЕ продукт и не заменяет его.
#
# Алфавит причин — ЕДИНЫЙ с будущим продуктом (батарея несёт его побайтово):
#   profil / workflowPaths / kanon-remote / komandy / source-canon
# Грамматика профиля — ТОЛЬКО действующий profile_resolver.sh (996: второй
# валидатор сырого профиля запрещён); модель читает его эффективный вывод.
# Сравнение remote — буквальное равенство целых строк (норма-класс 037).
# Пороговые правила: 0 — подключение структурно цело; 1 — ≥1 именованный
# отказ; 2 — неправильный вызов.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TOOLS="$(cd "$HERE/../../.." && pwd -P)"

REPO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:-}"; shift 2 ;;
    --repo=*) REPO="${1#--repo=}"; shift ;;
    *) printf 'model: неизвестный аргумент: %s\n' "$1" >&2; exit 2 ;;
  esac
done
[ -n "$REPO" ] && [ -d "$REPO" ] || { printf 'model: нет --repo <каталог>\n' >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { printf 'model: нет jq\n' >&2; exit 2; }
R="$(cd "$REPO" && pwd -P)"

itog=0
fail() { printf 'ОТКАЗ: подключение: %s: %s\n' "$1" "$2" >&2; itog=1; }

# ── profil: грамматика и слой — действующий резолвер ────────────────────────
export HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-$R}"
if ! OUT="$(bash "$TOOLS/scripts/profile_resolver.sh" --repo "$R" 2>&1)"; then
  printf 'ОТКАЗ: подключение: profil: %s\n' "$(printf '%s' "$OUT" | head -1)" >&2
  exit 1
fi

# ── workflowPaths (+ state): внутрь репо, каталог, без симлинк-побега ───────
for k in contracts verdicts registry fixtures; do
  v="$(printf '%s' "$OUT" | jq -r --arg k "$k" '.workflowPaths[$k].value // empty')"
  [ -n "$v" ] || { fail workflowPaths "workflowPaths.$k отсутствует в эффективном профиле"; continue; }
  case "$v" in /*) fail workflowPaths "workflowPaths.$k абсолютный: $v"; continue ;; esac
  p="$R/$v"
  [ -d "$p" ] || { fail workflowPaths "workflowPaths.$k не каталог: $v"; continue; }
  real="$(cd "$p" && pwd -P)"
  case "$real" in "$R"|"$R"/*) ;; *) fail workflowPaths "workflowPaths.$k канонически вне репо: $v" ;; esac
done
# STATE-112-BEG: state проверяется НЕЗАВИСИМО workflow-каталогов и файла слоя
# (батарея 112 вырезает этот блок по sentinels в state-слепую контрмодель —
# правило 3: клетки D14-state-vne-repo и D16-state-symlink-zveno обязаны быть
# красными против неё).
v="$(printf '%s' "$OUT" | jq -r '.workflowPaths.state.value // ".harness"')"
case "$v" in /*) fail workflowPaths "state абсолютный: $v" ;; *)
  p="$R/$v"; [ -d "$p" ] || fail workflowPaths "state не каталог: $v"
  real="$(cd "$p" 2>/dev/null && pwd -P || printf '%s' "$p")"
  case "$real" in "$R"|"$R"/*) ;; *) fail workflowPaths "state канонически вне репо: $v" ;; esac ;;
esac
# STATE-112-END

# ── kanon-remote: канон профиля = буквальный origin клона ───────────────────
canon="$(printf '%s' "$OUT" | jq -r '.git.value.canonicalRemote // empty')"
orig="$(git -C "$R" remote get-url origin 2>/dev/null || true)"
if [ -z "$canon" ] || [ -z "$orig" ] || [ "$canon" != "$orig" ]; then
  fail kanon-remote "канон профиля ≠ origin клона: ${canon:-<пусто>} ≠ ${orig:-<пусто>}"
fi

# KOMANDY-112-BEG: komandy — непустые, не `true`, реальны в дереве, форма
# ЗАКРЫТА (v3 — вердикты судей круга 1: F1/F2/F3). Путь файла и значение
# --prefix — ТОЛЬКО относительные и канонизируются ВНУТРЬ $R (образец —
# ветвь workflowPaths выше: cd && pwd -P + префикс-проверка): абсолютный
# путь и `..`-побег = отказ; операторы оболочки в любом токене и хвост
# после `run <s>`/`test` = отказ (форма не закрыта); голое имя без `run`
# = отказ. Честные литералы CI принимаются: `node|python3 <файл> [аргументы]`
# (например `node backend/scripts/gen-contracts.js --check`) и
# `npm [--prefix D] run <s>|test`. Батарея 112 вырезает этот блок по
# sentinels в komandy-слепую контрмодель — правило 3: клетки
# D34–D48 (вся komandy-семья, круг 3) обязаны быть красными против неё.
npm_script_ok() {  # $1 = package.json, $2 = имя скрипта
  jq -e --arg s "$2" '.scripts[$s] != null' "$1" >/dev/null 2>&1
}
op_obolochki() {  # $1 токен → 0, если токен несёт оператор/подстановку оболочки
  case "$1" in
    *\|*|*'&'*|*';'*|*'('*|*')'*|*'<'*|*'>'*|*'`'*|*'$'*) return 0 ;;
    *) return 1 ;;
  esac
}
for k in test build typecheck lint; do
  v="$(printf '%s' "$OUT" | jq -r --arg k "$k" '.commands[$k].value // empty')"
  if [ -z "$v" ] || [ "$v" = "true" ]; then fail komandy "commands.$k пустая или замаскирована true"; continue; fi
  set -f
  # shellcheck disable=SC2206
  toks=($v)
  set +f
  forma="ok"
  for t in "${toks[@]}"; do
    op_obolochki "$t" && forma="operator"
  done
  if [ "$forma" = "operator" ]; then fail komandy "commands.$k: оператор оболочки в команде: $v"; continue; fi
  case "${toks[0]}" in
    node|python3)
      f="${toks[1]-}"
      if [ -z "$f" ]; then fail komandy "commands.$k: нет файла после ${toks[0]}"; continue; fi
      case "$f" in
        /*) fail komandy "commands.$k: путь файла абсолютный: $f"; continue ;;
      esac
      fp="$(cd "$R/$(dirname "$f")" 2>/dev/null && pwd -P)/$(basename "$f")"
      case "$fp" in "$R"|"$R"/*) ;; *) fail komandy "commands.$k: файл канонически вне дерева: $f"; continue ;; esac
      [ -f "$fp" ] || fail komandy "commands.$k: файла нет в дереве: $f"
      continue ;;
    npm) ;;
    *) fail komandy "commands.$k вне известных семейств (npm/node/python3): $v"; continue ;;
  esac
  dir="$R"; i=0
  if [ "${toks[$((i+1))]-}" = "--prefix" ]; then
    d="${toks[$((i+2))]-}"
    if [ -z "$d" ]; then fail komandy "commands.$k: --prefix без значения: $v"; continue; fi
    case "$d" in
      /*) fail komandy "commands.$k: --prefix абсолютный: $d"; continue ;;
    esac
    dir="$(cd "$R/$d" 2>/dev/null && pwd -P)"
    if [ -z "$dir" ]; then fail komandy "commands.$k: каталог --prefix не читается: $d"; continue; fi
    case "$dir" in "$R"|"$R"/*) ;; *) fail komandy "commands.$k: --prefix канонически вне дерева: $d"; continue ;; esac
    i=2
  fi
  cur="${toks[$((i+1))]-}"
  case "$cur" in
    run)
      script="${toks[$((i+2))]-}"
      if [ -z "$script" ]; then fail komandy "commands.$k: run без имени скрипта: $v"; continue; fi
      if [ $((i+3)) -lt ${#toks[@]} ]; then fail komandy "commands.$k: хвост после 'run <скрипт>' — форма не закрыта: $v"; continue; fi ;;
    test)
      script="test"
      if [ $((i+2)) -lt ${#toks[@]} ]; then fail komandy "commands.$k: хвост после 'test' — форма не закрыта: $v"; continue; fi ;;
    *) fail komandy "commands.$k: npm вне закрытой формы 'run <скрипт>'|'test': $v"; continue ;;
  esac
  pj="$dir/package.json"
  [ -f "$pj" ] || { fail komandy "commands.$k: нет $pj"; continue; }
  npm_script_ok "$pj" "$script" || fail komandy "commands.$k: скрипта '$script' нет в ${pj#"$R"/}"
done
# KOMANDY-112-END

# ── source-canon: объявленные источники существуют (грамматика — резолвер) ──
n="$(printf '%s' "$OUT" | jq -r '.sourceCanon.value.sources // empty | length')"
[ "$n" = "0" ] || [ -z "$n" ] || for idx in $(seq 0 $((n-1))); do
  sp="$(printf '%s' "$OUT" | jq -r ".sourceCanon.value.sources[$idx].path")"
  case "$sp" in /*) fail source-canon "источник абсолютный: $sp" ;; *)
    [ -f "$R/$sp" ] || fail source-canon "источник отсутствует: $sp" ;;
  esac
done

exit "$itog"
