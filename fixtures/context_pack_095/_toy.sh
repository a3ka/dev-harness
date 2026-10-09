#!/usr/bin/env bash
# Каркас семьи context_pack_095 (контракт 095, круг 2) — toy-миры, субъект,
# разметка профиля/уроков/ADR/трассы.
#
# Субъект: scripts/make_task.sh (грамматика — model/dover.sh, честная модель).
# Клетки берут субъект из CP095_SUBJECT (раннер ставит real|model), дверь спавна
# — из CP095_SPAWN, корень дерева — из CP095_ROOT. Миры — ТОЛЬКО
# /tmp/dev-harness-verify/context-pack-095-** (Н-85/А-122), каждая клетка
# вычищает свой мир за собой (trap).
#
# Носители круга 2 — РЕАЛЬНЫЕ пути и грамматики (Б1 вердикта критика круга 1:
# проверяемый переход реальный-профиль → выдача; никакого toy-TSV
# harness/context-map в мире НЕТ):
#   <repo>/harness.project.json        — репо-слой профиля 054 с ключом
#                                        contextPack (rows/adrPath/lessonsPath);
#   <repo>/registry/harness-project.json — слой проекта 054: defaults.contextPack
#                                        (те же ключи, юнит-слияние массивов);
#   <repo>/registry/lessons-harness.tsv — реестр уроков (id TAB ОБЛАСТЬ-глоб TAB текст);
#   <repo>/decisions/NNN-slug.md       — ADR: шапка решение:/область:/статус:
#                                        (метки: path-glob | роль:<роль>);
#   <repo>/registry/plan.tsv           — реестр плана (GOAL брифинга);
#   <трасса>                           — TAB-строки: роль TAB модель TAB allowed|denied.
set -uo pipefail

t95_ni() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

_t95_subject() {  # путь субъекта: CP095_SUBJECT | <корень>/scripts/make_task.sh
  if [ -n "${CP095_SUBJECT:-}" ]; then printf '%s\n' "$CP095_SUBJECT"; return 0; fi
  local root="${CP095_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  printf '%s\n' "$root/scripts/make_task.sh"
}

_t95_door() {  # путь двери спавна: CP095_SPAWN | <корень>/scripts/spawn_agent.sh
  if [ -n "${CP095_SPAWN:-}" ]; then printf '%s\n' "$CP095_SPAWN"; return 0; fi
  local root="${CP095_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  printf '%s\n' "$root/scripts/spawn_agent.sh"
}

# _t95_world <слаг> — toy-мир: репозиторий проекта с настоящим профилем (два
# слоя 054), уроками, ADR, планом, черновиком контракта 777 и заданием.
# Печатает каталог мира. Оракулы (sha задания, §Существующее заморозки, план
# брифинга) клетки снимают в память ДО вызова субъекта (правило 8).
_t95_world() {
  local slug="$1" d
  d="/tmp/dev-harness-verify/context-pack-095-${slug}-$$-${RANDOM}"
  mkdir -p "$d/repo/contracts" "$d/repo/registry" "$d/repo/decisions" || t95_ni "мир не строится: $d"
  git init -q --initial-branch=main "$d/repo" 2>/dev/null || t95_ni "git init"
  git -C "$d/repo" config user.name architect
  git -C "$d/repo" config user.email architect@dev-harness.local

  # репо-слой профиля: contextPack с картой проекта (mandatory/optional как в 054)
  cat >"$d/repo/harness.project.json" <<'EOF'
{
  "schemaVersion": 1,
  "repoId": "toy-repo",
  "language": "bash",
  "projectLayer": { "version": "1", "profilePath": "registry/harness-project.json" },
  "workflowPaths": { "contracts": "contracts", "verdicts": "verdicts", "registry": "registry", "fixtures": "fixtures" },
  "commands": { "test": "bash fixtures/_krasnye_toy.sh", "build": "true", "typecheck": "true", "lint": "true" },
  "git": { "canonicalRemote": "ssh://git@example.invalid/toy/repo.git" },
  "ci": { "workflow": "ci.yml" },
  "barriers": { "mandatory": [], "optional": [] },
  "contextPack": {
    "rows": [
      { "kind": "map", "path": "PROJECT.md", "roles": "orchestrator,architect,critic,implementer,adversary,reviewer", "mandatory": true, "why": "карта проекта" },
      { "kind": "rules", "path": "DEVELOPMENT.md", "roles": "architect,implementer,reviewer", "mandatory": true, "why": "правила кодинга проекта" },
      { "kind": "reuse", "path": "MODULES.md", "roles": "architect,implementer", "mandatory": false, "why": "карта reuse" },
      { "kind": "rules", "path": "HARNESS-LEGACY.md", "roles": "architect", "mandatory": false, "why": "легаси-правила" }
    ],
    "adrPath": "decisions",
    "lessonsPath": "registry/lessons-harness.tsv"
  }
}
EOF

  # слой проекта: defaults.contextPack (юнит-слияние массива rows — прецедент
  # barriers.mandatory 054: репо-rows замещают defaults-rows ЦЕЛИКОМ)
  cat >"$d/repo/registry/harness-project.json" <<'EOF'
{
  "schemaVersion": 1,
  "version": "1",
  "projectId": "toy-project",
  "workspaceId": "toy-workspace",
  "defaults": {
    "language": "bash",
    "workflowPaths": { "contracts": "contracts", "verdicts": "verdicts", "registry": "registry", "fixtures": "fixtures" },
    "commands": { "test": "true", "build": "true", "typecheck": "true", "lint": "true" },
    "git": { "canonicalRemote": "ssh://git@example.invalid/toy/repo.git" },
    "ci": { "workflow": "ci.yml" },
    "barriers": { "mandatory": [], "optional": [] },
    "contextPack": {
      "rows": [
        { "kind": "map", "path": "DEFAULTS.md", "roles": "orchestrator,architect,critic,implementer,adversary,reviewer", "mandatory": true, "why": "проектный дефолт" }
      ],
      "adrPath": "decisions",
      "lessonsPath": "registry/lessons-harness.tsv"
    }
  }
}
EOF

  printf '# Карта проекта toy\nМодуль один: scripts/toy.sh\n' >"$d/repo/PROJECT.md"
  printf '# Правила кодинга toy\nПиши скучно.\n' >"$d/repo/DEVELOPMENT.md"
  printf '# Reuse\nПереиспользуй scripts/toy.sh.\n' >"$d/repo/MODULES.md"
  printf '# Дефолт слоя проекта\nКаждый pak из defaults.\n' >"$d/repo/DEFAULTS.md"

  # реестр уроков: id TAB ОБЛАСТЬ (path-glob) TAB текст; кап выдачи — 5
  {
    printf 'Н-71\tscripts/*\tзоны не по памяти\n'
    printf 'Н-39\tscripts/*\tстабы привязывай к ветвям\n'
    printf 'А-5\tdocs/*\tархивный урок чужой области\n'
    printf 'Н-12\tscripts/*\tчетвёртый урок зоны\n'
    printf 'Н-55\tscripts/*\tпятый урок зоны\n'
    printf 'Н-99\tscripts/*\tшестой урок сверх капа\n'
    printf 'Н-88\tscripts/*\tседьмой не пройдёт кап\n'
  } >"$d/repo/registry/lessons-harness.tsv"

  # реестр плана — GOAL-носитель брифинга (вербатим)
  {
    printf '# план toy\n'
    printf '777\t1\tдо V-2\t-\ttoy\ttrack\n'
    printf '888\t1\tдо V-2\t777\ttoy\ttrack\n'
  } >"$d/repo/registry/plan.tsv"
  printf '777 → 0000000000000000000000000000000000000000\n' >"$d/repo/registry/contracts.tsv"

  # ADR-каталог: шапка как у живых decisions/NNN-slug.md (дата/вопрос/решение/
  # основание/область/условие пересмотра); статус отсутствует = принято
  _t95_adr "$d/repo" 001 toy-modul '' 'scripts/*' 'единый toy-модуль'
  _t95_adr "$d/repo" 002 toy-roli '' 'роль:architect' 'архитектору — grilling и ADR'
  _t95_adr "$d/repo" 003 toy-zamenen 'заменено ADR-001' 'scripts/*' 'заменённый не выдаётся'
  _t95_adr "$d/repo" 004 toy-predlozheno 'предложено' 'scripts/*' 'предложенный не выдаётся'

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

  git -C "$d/repo" add -A
  git -C "$d/repo" commit -qm 'toy-мир 095'
  printf '%s\n' "$d"
}

# _t95_adr <repo> <id> <slug> <статус> <область> <решение> — живой формат
# decisions/NNN-slug.md; пустой статус = принято (действующее)
_t95_adr() {
  local repo="$1" id="$2" slug="$3" st="$4" area="$5" res="$6"
  {
    printf '# %s — toy ADR %s\n\n' "$id" "$slug"
    printf 'дата: 2026-10-09\n'
    printf 'вопрос: toy-вопрос %s\n' "$id"
    printf 'решение: %s\n' "$res"
    printf 'основание: 0000000\n'
    printf 'область: %s\n' "$area"
    printf 'условие пересмотра: toy\n'
    [ -n "$st" ] && printf 'статус: %s\n' "$st"
  } >"$repo/decisions/${id}-${slug}.md"
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
  git -C "$repo" commit -qm 'контракт 777' >/dev/null 2>&1 || true
  git -C "$repo" tag -f frozen/contracts/777/1 >/dev/null 2>&1
  printf 'frozen/contracts/777/1\n'
}

_t95_cleanup() { rm -rf "${1:-/tmp/dev-harness-verify/context-pack-095-НЕТ}"; }
