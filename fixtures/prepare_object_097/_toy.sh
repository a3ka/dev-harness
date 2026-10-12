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
# step-ключей реестра в порядке реестра; targetBranches= CSV из профиля (строки
# НЕТ, если ключа в профиле нет — живая сторона Н4-1).
_t97_policy_text() {
  local reg="$1" prof="$2" repo_id steps branches
  repo_id="$(sed -nE 's/^[[:space:]]*"repoId"[[:space:]]*:[[:space:]]*"([^"]*)".*$/\1/p' "$prof")"
  steps="$(LC_ALL=C awk '$1=="step" && $2!="" {printf "%s%s", sep, $2; sep=","}' "$reg")"
  branches="$(sed -nE 's/^[[:space:]]*"targetBranches"[[:space:]]*:[[:space:]]*\[(.*)\].*$/\1/p' "$prof" | tr -d '"' | sed 's/[[:space:]]//g')"
  printf 'repoId=%s\nmandatory=%s\n' "$repo_id" "$steps"
  [ -n "$branches" ] && printf 'targetBranches=%s\n' "$branches"
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

# _t97_cleanup <каталог мира> — регистрируется trap'ом клетки
_t97_cleanup() { rm -rf "$1" 2>/dev/null || true; }
