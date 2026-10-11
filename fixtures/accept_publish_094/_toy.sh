#!/usr/bin/env bash
# Каркас семьи accept_publish_094 (контракт 094 «принятие и публикация конкретного
# результата») — toy-миры, субъект, строки журнала.
#
# Субъект: scripts/accept_publish.sh (грамматика — model/dover.sh, честная модель).
# Клетки берут субъект из AP094_SUBJECT (раннер ставит real|model), корень дерева —
# из AP094_ROOT. Миры — ТОЛЬКО /tmp/dev-harness-verify/accept-publish-094-** (Н-85/А-122),
# каждая клетка вычищает свой мир за собой (trap).
#
# Политика toy-мира: <repo>/harness/policy на base SHA — три строки замкнутого
# алфавита (repoId/mandatory/targetBranches, И-0 контракта).
# Доверенные ОПРЕДЕЛЕНИЯ обязательных проверок: <repo>/harness/checks/<имя>.cmd
# на base SHA (И-4б: wfsha строки check = sha256 байтов определения на ДОВЕРЕННОЙ
# версии — единственный источник _t94_wfsha; поле «дерево» строки check = tree
# sha ИСПОЛНЕННОГО дерева — единственный источник _t94_tree; клетки не
# переизобретают ни то, ни другое). Журнал — TSV.
set -uo pipefail

t94_ni() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

_t94_subject() {  # путь субъекта: AP094_SUBJECT | <корень>/scripts/accept_publish.sh
  if [ -n "${AP094_SUBJECT:-}" ]; then printf '%s\n' "$AP094_SUBJECT"; return 0; fi
  local root="${AP094_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  printf '%s\n' "$root/scripts/accept_publish.sh"
}

# _t94_world <слаг> [targetBranches] — toy-мир: репо (main=base + ветка cand=
# кандидат), журнал. targetBranches по умолчанию main. Печатает каталог мира.
# Оракулы-sha клетки читают САМИ в память (git rev-parse) ДО вызова субъекта —
# на диске мира sha-файлов нет (правило 8).
_t94_world() {
  local slug="$1" branches="${2:-main}" d
  d="/tmp/dev-harness-verify/accept-publish-094-${slug}-$$-${RANDOM}"
  mkdir -p "$d/repo" || t94_ni "мир не строится: $d"
  git init -q --initial-branch=main "$d/repo" 2>/dev/null || t94_ni "git init"
  git -C "$d/repo" config user.name orchestrator
  git -C "$d/repo" config user.email orchestrator@dev-harness.local
  mkdir -p "$d/repo/harness/checks"
  printf 'repoId=toy-094\nmandatory=ci-a,ci-b\ntargetBranches=%s\n' "$branches" >"$d/repo/harness/policy"
  printf 'run ci-a\n' >"$d/repo/harness/checks/ci-a.cmd"
  printf 'run ci-b\n' >"$d/repo/harness/checks/ci-b.cmd"
  printf 'one\n' >"$d/repo/file.txt"
  git -C "$d/repo" add -A
  git -C "$d/repo" commit -qm 'base'
  git -C "$d/repo" checkout -qb cand
  printf 'two\n' >>"$d/repo/file.txt"
  git -C "$d/repo" commit -qam 'cand'
  git -C "$d/repo" checkout -q main
  : >"$d/journal.tsv"
  printf '%s\n' "$d"
}

# _t94_verdict <журнал> <seq> <задача> <object_id> <accept|fail>
_t94_verdict() { printf 'verdict\t%s\t%s\t%s\t%s\n' "$3" "$4" "$5" "$2" >>"$1"; }
# _t94_check <журнал> <object_id> <имя> <ok|fail> <run> <wfsha> <дерево>
# (дерево — 40 hex ИСПОЛНЕННОГО дерева, Б3/путь (а) арбитража 094; честный
# поставщик пишет дерево подготовленного merge — см. _t94_green)
_t94_check()   { printf 'check\t%s\t%s\t%s\t%s\t%s\t%s\n' "$2" "$3" "$4" "$5" "$6" "$7" >>"$1"; }
# _t94_policy <журнал> <object_id> <старая> <новая> <seq> — санкция перехода политики
_t94_policy()  { printf 'policy\t%s\t%s\t%s\taccept\t%s\n' "$2" "$3" "$4" "$5" >>"$1"; }

# _t94_wfsha <repo> <rev> <имя> — sha256 ДОВЕРЕННОГО определения проверки на rev
# (единственный источник wfsha; обманные клетки подставывают свой sha ЯВНО).
_t94_wfsha() { git -C "$1" show "$2:harness/checks/$3.cmd" 2>/dev/null | sha256sum | cut -d' ' -f1; }
# _t94_anysha <строка> — 64 hex из произвольной строки (для посторонних/подменённых имён)
_t94_anysha() { printf '%s' "$1" | sha256sum | cut -d' ' -f1; }
# _t94_tree <repo> <rev> — tree sha (40 hex) исполнения/объекта; единственный
# источник поля «дерево» строки check (клетки переизобретать его не вправе)
_t94_tree() { git -C "$1" rev-parse "$2^{tree}" 2>/dev/null; }

# _t94_green <repo> <base> <журнал> <object_id> <merge> — зелёные строки
# обязательных ci-a/ci-b: wfsha ДОВЕРЕННОЙ версии base + дерево подготовленного
# merge (честный поставщик судит ДЕРЕВО объекта — Решение 3, И-4б)
_t94_green() {
  local mt; mt="$(_t94_tree "$1" "$5")"
  _t94_check "$3" "$4" ci-a ok 1 "$(_t94_wfsha "$1" "$2" ci-a)" "$mt"
  _t94_check "$3" "$4" ci-b ok 2 "$(_t94_wfsha "$1" "$2" ci-b)" "$mt"
}

# _t94_cleanup <каталог-мира> — регистрируется trap'ом клетки
_t94_cleanup() { rm -rf "$1" 2>/dev/null || true; }
