#!/usr/bin/env bash
# scripts/project_workflow.sh — ТОНКАЯ ОБЁРТКА над функцией project_paths_resolve,
# размещённой в scripts/next_id.sh (ЗОНА implementer, контракт 996 Б-5/Б-9).
# Раньше эта дверь несла полный резолв-блок (profile_resolver, workflowPaths
# гард, state гард, jq-печать), и toy-миры (ap-фикстуры verify_antiplacebo,
# fixtures/freeze_contract/fail_closed_992.py) копировали её bash-скриптом
# в одноразовый мир, но НЕ копировали project_workflow.sh — каждая дверь
# (freeze/done/check_zones/check_staged/mint_line) вызывала её отдельным
# bash-процессом, и в toy-мире вызов отказывал «No such file or directory»
# (Н-340 красные клетки antiplacebo ap3/ap4/ap5 + obshchij).
#
# После Б-9: project_paths_resolve живёт В next_id.sh (а копия в lib_zones.sh
# для сценария check_hooks.sh). Двери импортируют её через source/next API
# и не вызывают этот скрипт как процесс. scripts/project_workflow.sh здесь —
# только ради обратной совместимости CLI (workshop/make_task/reserve/ci),
# и сводится к пересылке argv в функцию.
#
# Использование (тот же CLI, что был до рефакторинга):
#   bash scripts/project_workflow.sh --repo R --root R
# stdout — JSON ОДНОГО документа (ключи: contracts, verdicts, registry,
#           fixtures, handoff, observations, architectObservations, roadmap,
#           forks, sourceCanon). Тот же JSON, что у project_paths_resolve.
#
# Коды возврата:
#   0 — успех
#   1 — отказ с именованной причиной на stderr
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -x "$HERE/next_id.sh" ] || { printf 'ОТКАЗ: нет %s/next_id.sh\n' "$HERE" >&2; exit 1; }
NEXT_ID_LIB=1
# shellcheck disable=SC1091
. "$HERE/next_id.sh"

# project_paths_resolve принимает <REPO> позиционно. CLI-формат этой двери —
# --repo/--root <путь> либо просто путь; передаём всё как есть, оставляя разбор
# (включая трактовку `--`) самой функции. Функция берёт $1 как путь к репо.
REPO_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo|--root)
      REPO_ARG="${2:-}"
      [ $# -ge 2 ] && shift
      ;;
    --)
      shift
      [ $# -gt 0 ] && REPO_ARG="$1"
      break
      ;;
    *)
      [ -z "$REPO_ARG" ] && REPO_ARG="$1"
      ;;
  esac
  shift
done
if [ -z "$REPO_ARG" ]; then
  printf 'ОТКАЗ: usage: bash scripts/project_workflow.sh [--repo|--root] <путь>\n' >&2
  exit 1
fi

project_paths_resolve "$REPO_ARG"
