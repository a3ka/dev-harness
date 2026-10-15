#!/usr/bin/env bash
# Каркас семьи prepare_object_097 (контракт 097 «доверенная основа и подготовка
# объекта», часть А нарезки 094) — toy-миры двух профилей, оракулы id/merge.
#
# Субъект: scripts/accept_publish.sh (грамматика — fixtures/accept_publish_094/
# model/dover.sh, честная модель семьи 094; Решение 4 контракта 097: модель НЕ
# правится, отдельная не заводится). Клетки берут субъект из AP097_SUBJECT
# (раннер ставит real|model, стаб-пак — свой стаб), режим — из AP097_MODE
# (real|model; real-only пробы — семантика субъекта 097 сверх грамматики
# модели). Миры — ТОЛЬКО /tmp/dev-harness-verify/prepare-object-097-**
# (Н-85/А-122), клетка вычищает свои миры trap'ом.
#
# Профили (А-5):
#   харнес   — носители политики: registry/ci-steps.tsv (step-ключи реестра) и
#              harness.project.json (repoId/targetBranches); harness/policy —
#              КАНОНИЧЕСКИЙ текст, ВЫВЕДЕННЫЙ из носителей функцией
#              _t97_policy_text (единственный источник: миры несут эти байты
#              побайтово, рукописная правка запрещена; модель dover.sh и
#              реальный субъект сходятся на этих байтах);
#   проект   — носитель политики: текст harness/policy; пин слоя 054 И-5 в
#              harness.project.json (инертен для модели, читается резолвером
#              реального субъекта).
#
# Оракулы (правило 8: значения сняты в память ДО вызова субъекта; на диске мира
# sha-файлов нет): _t97_expected_id — каноническая строка объекта ПОБАЙТОВО по
# грамматике dover.sh (policyVersion = sha256 байтов политики; id = sha256
# TAB-строки семи полей, дословная строка printf модели); _t97_merge —
# merge-коммит оракула, независимо от субъекта.
set -uo pipefail

_t97_ni() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

_t97_subject() {  # путь субъекта: AP097_SUBJECT | <корень>/scripts/accept_publish.sh
  if [ -n "${AP097_SUBJECT:-}" ]; then printf '%s\n' "$AP097_SUBJECT"; return 0; fi
  local root="${AP097_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  printf '%s\n' "$root/scripts/accept_publish.sh"
}

_t97_mode() { printf '%s' "${AP097_MODE:-real}"; }

# _t97_policy_text <ci-steps.tsv> <harness.project.json> — канонический текст
# политики, выведенный из носителей: repoId= из профиля; mandatory= CSV
# step-ключей реестра в порядке реестра; targetBranches= CSV из профиля (строка
# ЕСТЬ ⟺ ключ в профиле есть: ключа нет — строки нет, живая сторона Н4-1; ключ
# с пустым массивом — пустой CSV-компонент «targetBranches=», неконформный И-0,
# вердикт адверсария v3 И-0).
_t97_policy_text() {
  local reg="$1" prof="$2" repo_id steps branches
  repo_id="$(sed -nE 's/^[[:space:]]*"repoId"[[:space:]]*:[[:space:]]*"([^"]*)".*$/\1/p' "$prof")"
  steps="$(LC_ALL=C awk '$1=="step" && $2!="" {printf "%s%s", sep, $2; sep=","}' "$reg")"
  branches="$(sed -nE 's/^[[:space:]]*"targetBranches"[[:space:]]*:[[:space:]]*\[(.*)\].*$/\1/p' "$prof" | tr -d '"' | sed 's/[[:space:]]//g')"
  printf 'repoId=%s\nmandatory=%s\n' "$repo_id" "$steps"
  grep -qE '^[[:space:]]*"targetBranches"[[:space:]]*:' "$prof" && printf 'targetBranches=%s\n' "$branches"
  return 0
}

# _t97_regen <repo> — перегенерировать harness/policy из носителей текущего дерева
_t97_regen() { _t97_policy_text "$1/registry/ci-steps.tsv" "$1/harness.project.json" >"$1/harness/policy"; }

# _t97_git_init <каталог-repo> — общий скелет инициализации toy-репозитория
_t97_git_init() {
  git init -q --initial-branch=main "$1" 2>/dev/null || _t97_ni "git init"
  git -C "$1" config user.name orchestrator
  git -C "$1" config user.email orchestrator@dev-harness.local
}

# _t97_world_harness <слаг> — мир профиля харнеса: base (main) = реестр
# ci-a,ci-b + профиль repoId=toy-harness-097/targetBranches=[main] +
# выведенный канонический текст; ветка cand — правка файла. Печатает каталог
# мира. Варианты клеток правят носители ТОЛЬКО в СВОИХ коммитах + _t97_regen.
_t97_world_harness() {
  local slug="$1" d
  d="/tmp/dev-harness-verify/prepare-object-097-${slug}-$$-${RANDOM}"
  mkdir -p "$d/repo/registry" "$d/repo/harness" || _t97_ni "мир не строится: $d"
  _t97_git_init "$d/repo"
  printf '# toy-реестр шагов (семья 097)\nstep ci-a 1 bash true\nstep ci-b 1 bash true\n' >"$d/repo/registry/ci-steps.tsv"
  printf '{\n  "repoId": "toy-harness-097",\n  "targetBranches": ["main"]\n}\n' >"$d/repo/harness.project.json"
  _t97_regen "$d/repo"
  printf 'one\n' >"$d/repo/file.txt"
  git -C "$d/repo" add -A && git -C "$d/repo" commit -qm base
  git -C "$d/repo" checkout -qb cand
  printf 'two\n' >>"$d/repo/file.txt"
  git -C "$d/repo" commit -qam cand
  git -C "$d/repo" checkout -q main
  printf '%s\n' "$d"
}

# _t97_world_project <слаг> — мир проектного слоя: base (main) = текст
# harness/policy (repoId=toy-proj-097, mandatory=p-a,p-b, targetBranches=main)
# + пин слоя 054 И-5 (harness.project.json → registry/harness-project.json);
# ветка cand — правка файла. Печатает каталог мира.
_t97_world_project() {
  local slug="$1" d
  d="/tmp/dev-harness-verify/prepare-object-097-${slug}-$$-${RANDOM}"
  mkdir -p "$d/repo/harness" "$d/repo/registry" || _t97_ni "мир не строится: $d"
  _t97_git_init "$d/repo"
  printf 'repoId=toy-proj-097\nmandatory=p-a,p-b\ntargetBranches=main\n' >"$d/repo/harness/policy"
  printf '{\n  "repoId": "toy-proj-097",\n  "projectLayer": { "version": "1", "profilePath": "registry/harness-project.json" }\n}\n' >"$d/repo/harness.project.json"
  printf '{\n  "version": "1",\n  "repoId": "toy-proj-097"\n}\n' >"$d/repo/registry/harness-project.json"
  printf 'one\n' >"$d/repo/file.txt"
  git -C "$d/repo" add -A && git -C "$d/repo" commit -qm root
  printf 'two\n' >>"$d/repo/file.txt"
  git -C "$d/repo" add -A && git -C "$d/repo" commit -qm base
  git -C "$d/repo" checkout -qb cand
  printf 'three\n' >>"$d/repo/file.txt"
  git -C "$d/repo" commit -qam cand
  git -C "$d/repo" checkout -q main
  printf '%s\n' "$d"
}

# _t97_expected_id <repo> <rev-политики> <task> <target> <base> <cand> <merge>
# — оракул id: policyVersion = sha256 байтов политики на ДОверенной версии,
# снятых в память ДО вызова субъекта; каноническая строка — дословный printf
# модели dover.sh (строка object_id, грамматика И-1б).
_t97_expected_id() {
  local repo="$1" rev="$2" task="$3" target="$4" base="$5" cand="$6" merge="$7" bytes pv rid
  bytes="$(git -C "$repo" show "$rev:harness/policy" 2>/dev/null)" || return 2
  pv="$(printf '%s' "$bytes" | sha256sum | cut -d' ' -f1)"
  rid="$(printf '%s' "$bytes" | sed -nE 's/^repoId=(.+)$/\1/p')"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$rid" "$task" "$target" "$base" "$cand" "$merge" "$pv" | sha256sum | cut -d' ' -f1
}

# _t97_merge <repo> <base> <cand> [сообщение] — merge-коммит ОРАКУЛОМ
# (merge-tree + commit-tree), независимо от субъекта
_t97_merge() {
  local tree
  tree="$(git -C "$1" merge-tree --write-tree --no-messages "$2" "$3" 2>/dev/null)" || return 2
  git -C "$1" commit-tree "$tree" -p "$2" -p "$3" -m "${4:-oracle-merge}"
}

# ── наблюдатели А-8 (арбитраж contracts-097-refs-v1 п.5а/5е): два обязательны ──
# (1) хук reference-transaction мира (core.hooksPath мира; путь журнала вшит в
# текст хука, не передаётся окружением): за вызов prepare — ноль записей;
# калибровка ДО пробы — сама создаёт и удаляет временную ref и требует записей
# хука, иначе rc 2 «нечем проверять». (2) снимок for-each-ref (имя,
# objectname, symref) + строка HEAD <sha> <цель|detached>, снятый в память ДО
# вызова (правило 8), байт-в-байт равен ПОСЛЕ; пустая выборка красна. Каждый
# наблюдатель ловит то, что слеп другому (замер 2 арбитража: symref мимо
# транзакций; временная ref мимо снимка) — сверяются ОБА на КАЖДОМ вызове
# prepare в семье, успешном и отказном.
_t97_refs_arm() {  # <repo> — наблюдатель (1): поставить хук, откалибровать, обнулить журнал
  local repo="$1" wd hooks sha
  wd="$(dirname "$repo")"; hooks="$wd/ref-hooks"
  mkdir -p "$hooks" || return 2
  cat >"$hooks/reference-transaction" <<HOOK
#!/bin/sh
# t97: наблюдатель (1) А-8 — путь журнала вшит в текст хука
printf '%s %s\n' "\$1" "\$(cat)" >>'$wd/ref-tx.log'
exit 0
HOOK
  chmod +x "$hooks/reference-transaction" || return 2
  git -C "$repo" config core.hooksPath "$hooks" || return 2
  : >"$wd/ref-tx.log" || return 2
  sha="$(git -C "$repo" rev-parse HEAD)" || return 2
  git -C "$repo" update-ref refs/_t97_calib "$sha" >/dev/null 2>&1 || return 2
  git -C "$repo" update-ref -d refs/_t97_calib >/dev/null 2>&1 || return 2
  [ -s "$wd/ref-tx.log" ] || {
    printf 'NOT_IMPLEMENTED: нечем проверять: хук reference-transaction не срабатывает\n' >&2
    return 2
  }
  : >"$wd/ref-tx.log" || return 2
}

_t97_refs_snap() {  # <repo> — наблюдатель (2): снимок refs+symref+HEAD в память (правило 8)
  local repo="$1" h sym
  h="$(git -C "$repo" rev-parse HEAD)" || return 2
  sym="$(git -C "$repo" symbolic-ref -q HEAD)" || true
  git -C "$repo" for-each-ref --format='%(refname) %(objectname) %(symref)' || return 2
  printf 'HEAD %s %s\n' "$h" "${sym:-detached}"
}

_t97_refs_check() {  # <repo> <снимок-до> — оба наблюдателя А-8; rc 1 красная, rc 2 нечем проверять
  local repo="$1" before="$2" after journal
  case "$(printf '%s\n' "$before" | sed -n 1p)" in
    'HEAD '*) printf 'КРАСНО: refs-наблюдатели (А-8): пустая выборка refs — сверять нечего\n' >&2; return 1 ;;
  esac
  after="$(_t97_refs_snap "$repo")" || return 2
  journal="$(dirname "$repo")/ref-tx.log"
  if [ -s "$journal" ]; then
    printf 'КРАСНО: refs-наблюдатели (А-8): за вызов prepare были транзакции над refs (хук reference-transaction):\n%s\n' "$(cat "$journal")" >&2
    return 1
  fi
  if [ "$after" != "$before" ]; then
    printf 'КРАСНО: refs-наблюдатели (А-8): снимок refs изменился (обещание «не трогает ни одной ref»):\nДО:\n%s\nПОСЛЕ:\n%s\n' "$before" "$after" >&2
    return 1
  fi
  return 0
}

# _t97_cleanup <каталог мира> — регистрируется trap'ом клетки
_t97_cleanup() { rm -rf "$1" 2>/dev/null || true; }
