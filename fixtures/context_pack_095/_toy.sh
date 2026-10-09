#!/usr/bin/env bash
# Каркас семьи context_pack_095 (контракт 095 «Профиль и вход агента — узкий
# настоящий ContextPack») — toy-миры, субъект, разметка карты/уроков/трассы.
#
# Субъект: scripts/make_task.sh (грамматика — model/dover.sh, честная модель).
# Клетки берут субъект из CP095_SUBJECT (раннер ставит real|model), корень
# дерева — из CP095_ROOT. Миры — ТОЛЬКО /tmp/dev-harness-verify/context-pack-095-**
# (Н-85/А-122), каждая клетка вычищает свой мир за собой (trap).
#
# Toy-носители (грамматика значений ДОСЛОВНО как у субъекта, И-0 контракта;
# реальный носитель — контекстные ключи профиля через живой profile_resolver,
# toy-файл несёт ту же грамматику ЗНАЧЕНИЙ, прецедент «toy-строка политики» 094):
#   <repo>/harness/context-map — TAB-строки: kind ∈ {map,rules,reuse} TAB path
#     TAB roles (CSV из алфавита ролей) TAB mandatory|optional TAB why;
#   <repo>/harness/lessons — TAB-строки: id TAB ОБЛАСТЬ (path-glob) TAB текст;
#   <трасса> — TAB-строки: роль TAB модель TAB allowed|denied.
set -uo pipefail

t95_ni() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

_t95_subject() {  # путь субъекта: CP095_SUBJECT | <корень>/scripts/make_task.sh
  if [ -n "${CP095_SUBJECT:-}" ]; then printf '%s\n' "$CP095_SUBJECT"; return 0; fi
  local root="${CP095_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  printf '%s\n' "$root/scripts/make_task.sh"
}

# _t95_world <слаг> — toy-мир: проект-репо с картой/уроками/черновиком контракта
# 777. Печатает каталог мира. Оракулы (sha задания, ЗОНА-строки заморозки)
# клетки снимают в память ДО вызова субъекта (правило 8). HARNESS-LEGACY.md
# (optional-запись) СОЗНАТЕЛЬНО отсутствует: optional-пропуск легален (И-3б),
# mandatory-пропуск — именованный отказ (И-3а, клетка удаляет файл).
_t95_world() {
  local slug="$1" d
  d="/tmp/dev-harness-verify/context-pack-095-${slug}-$$-${RANDOM}"
  mkdir -p "$d/repo/harness" "$d/repo/contracts" || t95_ni "мир не строится: $d"
  git init -q --initial-branch=main "$d/repo" 2>/dev/null || t95_ni "git init"
  git -C "$d/repo" config user.name architect
  git -C "$d/repo" config user.email architect@dev-harness.local
  {
    printf 'map\tPROJECT.md\torchestrator,architect,critic,implementer,adversary,reviewer\tmandatory\tкарта проекта\n'
    printf 'rules\tDEVELOPMENT.md\tarchitect,implementer,reviewer\tmandatory\tправила кодинга проекта\n'
    printf 'reuse\tMODULES.md\tarchitect,implementer\toptional\tкарта reuse\n'
    printf 'rules\tHARNESS-LEGACY.md\tarchitect\toptional\tлегаси-правила\n'
  } >"$d/repo/harness/context-map"
  printf '# Карта проекта toy\nМодуль один: scripts/toy.sh\n' >"$d/repo/PROJECT.md"
  printf '# Правила кодинга toy\nПиши скучно.\n' >"$d/repo/DEVELOPMENT.md"
  printf '# Reuse\nПереиспользуй scripts/toy.sh.\n' >"$d/repo/MODULES.md"
  {
    printf 'Н-71\tscripts/*\tзоны не по памяти\n'
    printf 'Н-39\tscripts/*\tстабы привязывай к ветвям\n'
    printf 'А-5\tdocs/*\tархивный урок чужой области\n'
    printf 'Н-12\tscripts/*\tчетвёртый урок зоны\n'
    printf 'Н-55\tscripts/*\tпятый урок зоны\n'
    printf 'Н-99\tscripts/*\tшестой урок сверх капа\n'
    printf 'Н-88\tscripts/*\tседьмой не пройдёт кап\n'
  } >"$d/repo/harness/lessons"
  cat >"$d/repo/contracts/777-toy.md" <<'EOF'
# Контракт 777 — toy

КОНТЕКСТ: модуль toy, сосед один

## Существующее

- scripts/toy.sh — живой код

## Предмет

toy-предмет.

ЗОНА implementer: scripts/toy.sh
ЗОНА architect: contracts/777-toy.md
EOF
  printf 'Задание toy: сделай хорошо.\n' >"$d/task.md"
  printf '%s\n' "$d"
}

# _t95_trace <файл> <роль> <модель> <allowed|denied> — строка трассы модели
_t95_trace() { printf '%s\t%s\t%s\n' "$2" "$3" "$4" >>"$1"; }

# _t95_freeze <repo> <зона-строка-implementer> — фиксирует contracts/777-toy.md
# с ДАННОЙ ЗОНА-строкой в тег frozen/contracts/777/1 (клетка потом расходит
# заморозку и черновик). Печатает тег.
_t95_freeze() {
  local repo="$1" zline="$2"
  sed -i "s@^ЗОНА implementer: .*@ЗОНА implementer: $zline@" "$repo/contracts/777-toy.md"
  git -C "$repo" add -A
  git -C "$repo" commit -qm 'контракт 777'
  git -C "$repo" tag frozen/contracts/777/1
  printf 'frozen/contracts/777/1\n'
}

_t95_cleanup() { rm -rf "${1:-/tmp/dev-harness-verify/context-pack-095-НЕТ}"; }
