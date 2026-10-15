#!/usr/bin/env bash
# Каркас семьи project_paths_103 (контракт 103 «профильные пути вместо
# harness-layout») — toy-миры с НЕСТАНДАРТНОЙ раскладкой workflowPaths и
# Complior-подобный шаблон проекта для стандарта §1.
#
# Субъекты (клетки берут из окружения, раннер ставит real|model):
#   PP103_MAKE_TASK  — scripts/make_task.sh              | model/kontrakt_po_profilju.sh
#   PP103_PRE_CRITIC — scripts/pre_critic.sh             | model/pre_critic_proekta.sh
#   PP103_SPAWN      — scripts/spawn_agent.sh            | model/dver_reestra.sh
#   PP103_STANDARD   — scripts/check_project_standard.sh | model/check_project_standard.sh
#   PP103_ROOT       — корень дерева харнеса.
# Миры — ТОЛЬКО /tmp/dev-harness-verify/project-paths-103-** (Н-85/А-122),
# каждая клетка вычищает свой мир (trap).
#
# Раскладка toy-репо (И-1): workflowPaths = {contracts: tasks/h, verdicts:
# tasks/v, registry: tasks/reg, fixtures: tasks/fx}; в корне НЕТ contracts/,
# registry/, verdicts/, fixtures/. Профиль — два слоя 054 по РЕАЛЬНЫМ
# путям (harness.project.json + слой проекта по projectLayer.profilePath,
# здесь tasks/reg/harness-project.json).
set -uo pipefail

t103_ni() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

_t103_subj() {  # <ИМЯ-ПЕРЕМЕННОЙ> <относительный путь в харнесе>
  local v="${!1:-}"
  [ -n "$v" ] && { printf '%s' "$v"; return; }
  printf '%s/%s' "${PP103_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}" "$2"
}
_t103_make_task()  { _t103_subj PP103_MAKE_TASK  scripts/make_task.sh; }
_t103_pre_critic() { _t103_subj PP103_PRE_CRITIC scripts/pre_critic.sh; }
_t103_spawn()      { _t103_subj PP103_SPAWN      scripts/spawn_agent.sh; }
_t103_standard()   { _t103_subj PP103_STANDARD   scripts/check_project_standard.sh; }

_t103_trace() { printf '%s\t%s\t%s\n' "$2" "$3" "$4" >>"$1"; }
_t103_cleanup() { rm -rf "${1:-/tmp/dev-harness-verify/project-paths-103-НЕТ}"; }

# Уникальная строка §Существующее toy-контракта — оракул И-1 (grep -Fx в паке).
T103_UNIQ='- tasks/h/777-toy.md — уникальная-строка-103-h7q2'

# _t103_profile <repo> <contracts> <verdicts> <registry> <fixtures> — пишет оба слоя
# профиля с данными workflowPaths (слой проекта лежит по tasks/reg всегда:
# profilePath не зависит от значения workflowPaths.registry).
_t103_profile() {
  local r="$1" c="$2" v="$3" g="$4" f="$5"
  mkdir -p "$r/tasks/reg"
  cat >"$r/harness.project.json" <<EOF
{
  "schemaVersion": 1,
  "repoId": "toy-103",
  "language": "bash",
  "projectLayer": { "version": "1", "profilePath": "tasks/reg/harness-project.json" },
  "workflowPaths": { "contracts": "$c", "verdicts": "$v", "registry": "$g", "fixtures": "$f" },
  "commands": { "test": "bash tasks/fx/_krasnye_toy.sh", "build": "true", "typecheck": "true", "lint": "true" },
  "git": { "canonicalRemote": "ssh://git@example.invalid/toy/103.git" },
  "ci": { "workflow": ".github/workflows/ci.yml" },
  "barriers": { "mandatory": [], "optional": [] },
  "contextPack": {
    "rows": [
      { "kind": "map", "path": "PROJECT.md", "roles": "orchestrator,architect,critic,implementer,adversary,reviewer", "mandatory": true, "why": "карта проекта" },
      { "kind": "rules", "path": "AGENTS.md", "roles": "orchestrator,architect,critic,implementer,adversary,reviewer", "mandatory": true, "why": "правила проекта" }
    ],
    "lessonsPath": "tasks/reg/lessons.tsv"
  }
}
EOF
  cat >"$r/tasks/reg/harness-project.json" <<EOF
{
  "schemaVersion": 1,
  "version": "1",
  "projectId": "toy-103-project",
  "workspaceId": "toy-103-workspace",
  "defaults": {
    "language": "bash",
    "workflowPaths": { "contracts": "$c", "verdicts": "$v", "registry": "$g", "fixtures": "$f" },
    "commands": { "test": "true", "build": "true", "typecheck": "true", "lint": "true" },
    "git": { "canonicalRemote": "ssh://git@example.invalid/toy/103.git" },
    "ci": { "workflow": ".github/workflows/ci.yml" },
    "barriers": { "mandatory": [], "optional": [] }
  }
}
EOF
}

# _t103_contract <файл> <NNN> — toy-контракт полной формы (КОНТЕКСТ:, §Существующее,
# ЗОНА, ПРОВОДКА) с уникальной строкой-оракулом.
_t103_contract() {
  cat >"$1" <<EOF
# Контракт $2 — toy 103

КОНТЕКСТ: модуль toy, сосед один

## Существующее

$T103_UNIQ

## Предмет

toy-предмет 103.

## Приёмка

1. Дано: мир; когда: bash tasks/fx/_krasnye_toy.sh; тогда: rc 0.

ЗОНА implementer: scripts/toy.sh
ЗОНА architect: tasks/h/$2-toy.md

## ПРОВОДКА

ПРОВОДКА:
- guard=tasks/fx/_krasnye_toy.sh
EOF
}

# _t103_world <слаг> — toy-репо с нестандартной раскладкой; контракт 777 ТОЛЬКО
# в tasks/h. Печатает каталог мира (репо — <мир>/repo).
# Toy несёт инфраструктуру паритета CI (`.github/workflows/ci.yml` ↔
# package.json scripts ↔ config/ci_parity_exceptions.txt): ноги (а)/(б)
# pre_critic на --repo зовут check_precision_gate.sh/check_spec_ready.sh с R
# (Frontier И-2), а precision-гейт 043 задачей (в) требует verify_ci_parity.sh
# rc 0 — без `.github` он даёт «сверять не с чем» (rc 2 → красен). Это дефект
# toy, не повод разоружать ноги (§Остаточный риск контракта 103; Рв96-3).
_t103_world() {
  local slug="$1" d
  d="/tmp/dev-harness-verify/project-paths-103-${slug}-$$-${RANDOM}"
  mkdir -p "$d/repo/tasks/h" "$d/repo/tasks/v" "$d/repo/tasks/reg" "$d/repo/tasks/fx" || t103_ni "мир не строится: $d"
  git init -q --initial-branch=main "$d/repo" 2>/dev/null || t103_ni "git init"
  git -C "$d/repo" config user.name architect
  git -C "$d/repo" config user.email architect@dev-harness.local
  _t103_profile "$d/repo" tasks/h tasks/v tasks/reg tasks/fx
  printf '# Карта проекта toy 103\nМодуль один: scripts/toy.sh\n' >"$d/repo/PROJECT.md"
  printf '# AGENTS toy 103\nПиши скучно.\n' >"$d/repo/AGENTS.md"
  printf 'Н-71\tscripts/*\tзоны не по памяти\n' >"$d/repo/tasks/reg/lessons.tsv"
  printf '# план toy\n777\t1\tдо V-2\t-\ttoy\ttrack\n' >"$d/repo/tasks/reg/plan.tsv"
  printf '777 → 0000000000000000000000000000000000000000\n' >"$d/repo/tasks/reg/contracts.tsv"
  printf '#!/usr/bin/env bash\nexit 0\n' >"$d/repo/tasks/fx/_krasnye_toy.sh"
  mkdir -p "$d/repo/.github/workflows" "$d/repo/config"
  printf 'name: ci\non: [push]\njobs:\n  test:\n    runs-on: ubuntu-latest\n    steps:\n      - run: npm run test\n' >"$d/repo/.github/workflows/ci.yml"
  printf '{ "name": "toy-103", "version": "0.0.1", "scripts": { "test": "bash tasks/fx/_krasnye_toy.sh" } }\n' >"$d/repo/package.json"
  printf '# паритет CI toy 103: все скрипты package.json исполняются в ci.yml, исключений нет\n' >"$d/repo/config/ci_parity_exceptions.txt"
  mkdir -p "$d/repo/scripts"; printf '#!/usr/bin/env bash\n' >"$d/repo/scripts/toy.sh"
  _t103_contract "$d/repo/tasks/h/777-toy.md" 777
  git -C "$d/repo" add -A
  git -C "$d/repo" commit -qm 'toy-мир 103'
  printf '%s\n' "$d"
}

# _t103_world_sloj_vne <слаг> — тот же toy, но слой проекта лежит ВНЕ репо
# (<мир>/layer/tasks/reg/harness-project.json; потребители получают его через
# HARNESS_PROJECT_LAYER_ROOT=<мир>/layer), а репо-слой harness.project.json
# НЕ объявляет workflowPaths (схема 054: в репо-слое ключ необязателен) — как у
# Complior/odelix-stack. В R нет tasks/reg/harness-project.json. Эффективный
# workflowPaths.registry=tasks/reg существует ТОЛЬКО через profile_resolver.sh;
# «второй резолвер» (свой jq по R) его не видит (Рв96-2). Печатает каталог мира.
_t103_world_sloj_vne() {
  local d r
  d="$(_t103_world "$1")" || return 2
  r="$d/repo"
  mkdir -p "$d/layer/tasks/reg" || t103_ni "слой вне репо не строится: $d"
  mv "$r/tasks/reg/harness-project.json" "$d/layer/tasks/reg/harness-project.json" || t103_ni "перенос слоя"
  jq 'del(.workflowPaths)' "$r/harness.project.json" >"$r/harness.project.json.new" || t103_ni "jq del workflowPaths"
  mv "$r/harness.project.json.new" "$r/harness.project.json"
  git -C "$r" add -A
  git -C "$r" commit -qm 'слой проекта вне репо; репо-слой без workflowPaths'
  printf '%s\n' "$d"
}

# _t103_complior <слаг> — Complior-подобный эталон стандарта §1 (Node-проект с
# npm-скриптами, lockfile, AGENTS.md, .env.example, игнорируемый .env, пин
# харнеса, origin с main, профиль двух слоёв по раскладке .harness/*).
# Печатает каталог мира (репо — <мир>/repo, origin — <мир>/origin.git).
_t103_complior() {
  local slug="$1" d r
  d="/tmp/dev-harness-verify/project-paths-103-${slug}-$$-${RANDOM}"
  r="$d/repo"
  mkdir -p "$r/.harness/contracts" "$r/.harness/verdicts" "$r/.harness/registry" "$r/.harness/fixtures" \
           "$r/config" "$r/app" "$r/tests" "$r/docs" "$r/.github/workflows" || t103_ni "мир не строится: $d"
  git init -q --bare --initial-branch=main "$d/origin.git" 2>/dev/null || t103_ni "git init origin"
  git init -q --initial-branch=main "$r" 2>/dev/null || t103_ni "git init"
  git -C "$r" config user.name architect
  git -C "$r" config user.email architect@dev-harness.local
  git -C "$r" remote add origin "$d/origin.git"
  cat >"$r/harness.project.json" <<'EOF'
{
  "schemaVersion": 1,
  "repoId": "complior-backend",
  "language": "typescript",
  "projectLayer": { "version": "1", "profilePath": ".harness/registry/harness-project.json" },
  "workflowPaths": { "contracts": ".harness/contracts", "verdicts": ".harness/verdicts", "registry": ".harness/registry", "fixtures": ".harness/fixtures" },
  "commands": { "test": "npm test", "build": "npm run build", "typecheck": "npm run typecheck", "lint": "npm run lint" },
  "git": { "canonicalRemote": "ssh://git@github.invalid/a3ka/Complior-mob.git" },
  "ci": { "workflow": ".github/workflows/ci.yml" },
  "barriers": { "mandatory": [], "optional": [] },
  "contextPack": {
    "rows": [
      { "kind": "map", "path": "docs/ARCHITECTURE.md", "roles": "orchestrator,architect,critic,implementer,adversary,reviewer", "mandatory": true, "why": "карта" },
      { "kind": "rules", "path": "AGENTS.md", "roles": "orchestrator,architect,critic,implementer,adversary,reviewer", "mandatory": true, "why": "правила" }
    ]
  }
}
EOF
  cat >"$r/.harness/registry/harness-project.json" <<'EOF'
{
  "schemaVersion": 1,
  "version": "1",
  "projectId": "complior",
  "workspaceId": "complior-ws",
  "defaults": {
    "language": "typescript",
    "workflowPaths": { "contracts": ".harness/contracts", "verdicts": ".harness/verdicts", "registry": ".harness/registry", "fixtures": ".harness/fixtures" },
    "commands": { "test": "npm test", "build": "npm run build", "typecheck": "npm run typecheck", "lint": "npm run lint" },
    "git": { "canonicalRemote": "ssh://git@github.invalid/a3ka/Complior-mob.git" },
    "ci": { "workflow": ".github/workflows/ci.yml" },
    "barriers": { "mandatory": [], "optional": [] }
  }
}
EOF
  printf '# Архитектура\napp/ — API.\n' >"$r/docs/ARCHITECTURE.md"
  printf '# AGENTS\nНазначение, карта входов, команды, границы, запреты.\n' >"$r/AGENTS.md"
  printf '{ "name": "complior-backend", "version": "0.0.1", "scripts": { "test": "node tests/run.js", "lint": "eslint .", "typecheck": "tsc --noEmit", "build": "tsc" } }\n' >"$r/package.json"
  printf '{ "name": "complior-backend", "lockfileVersion": 3, "packages": {} }\n' >"$r/package-lock.json"
  printf 'DATABASE_URL=postgres://localhost/complior_dev\n' >"$r/.env.example"
  printf 'DATABASE_URL=postgres://localhost/complior_dev_secret\n' >"$r/.env"
  printf '.env\nnode_modules/\n' >"$r/.gitignore"
  printf '{ "version": "0.9.0" }\n' >"$r/config/harness_pin.json"
  printf 'name: ci\non: [pull_request, push]\njobs: { test: { runs-on: ubuntu-latest, steps: [ { run: npm ci }, { run: npm test } ] } }\n' >"$r/.github/workflows/ci.yml"
  printf 'process.exit(0);\n' >"$r/tests/run.js"
  printf '777 → 0000000000000000000000000000000000000000\n' >"$r/.harness/registry/contracts.tsv"
  git -C "$r" add -A
  git -C "$r" commit -qm 'эталон Complior 103'
  git -C "$r" push -q origin main 2>/dev/null || t103_ni "push в origin"
  printf '%s\n' "$d"
}
