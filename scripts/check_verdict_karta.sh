#!/usr/bin/env bash
# ДВЕРЬ КАРТЫ КЛАССОВ ВЕРДИКТА (контракт 193, Л2).
#
#   bash scripts/check_verdict_karta.sh <корень> <отн-путь-вердикта>
#
# Судит ТОЛЬКО ЗАКОММИЧЕННЫЙ вердикт (AGENTS.md п.8/9: истина — в закоммиченном
# исходнике; вердикт в переписке не переживает сессию): текст читается из
# HEAD-блоба, рабочее дерево не спрашивается. Грамматика секции «## Карта
# классов» — ЕДИНЫЙ ИСТОЧНИК scripts/lib_karta_sdachi.sh (И7); эта дверь
# грамматику не переизобретает.
#
# ГРАММАТИКА ПУТИ (И7, путевая часть по слову владельца 2026-11-18 №3): путь
# вердикта — непустой относительный путь внутри critic-каталога ЭФФЕКТИВНОГО
# workflowPaths.verdicts, который отдаёт ЕДИНЫЙ резолвер scripts/next_id.sh
# (project_paths_resolve, контракт 996). Без профиля резолвер отдаёт штатную
# корневую раскладку `verdicts/critic/…`; при ПРОФИЛЬНОМ каталоге корневой
# `verdicts/critic/…` запасным источником НЕ является (корень не запасной
# источник, 996 К6) — приманка на корне отвергается тем же отказом, что и любой
# чужой путь. Каталог НЕ хардкодится: `.harness/verdicts` — пример имени, а не
# константа; никаких двух глобальных разрешений вида
# {verdicts/critic/*, .harness/verdicts/critic/*}, никакого шаблона
# `*/verdicts/critic/*`, никакого свободного префикса из argv или env.
# Отказ резолвера (битый профиль, workflowPaths вне репо, симлинк-побег) —
# именованный отказ БЕЗ fallback на корневую раскладку: «профиля нет» и
# «профиль бит» — разные случаи.
#
# Коды возврата:
#   0 — карта валидна, stdout «КАРТА: 17/17 зелёный»;
#   1 — именованный отказ «ОТКАЗ: …»;
#   2 — NOT_IMPLEMENTED (нет git/jq/sed, нет корня, нет соседних библиотек).

set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES \
      GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

otkaz() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
ni()    { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git >/dev/null 2>&1  || ni 'нет git'
command -v sed >/dev/null 2>&1 || ni 'нет sed'
command -v jq  >/dev/null 2>&1 || ni 'нет jq'

[ $# -eq 2 ] || { printf 'использование: check_verdict_karta.sh <корень> <вердикт>\n' >&2; exit 1; }
ROOT="$(cd "$1" 2>/dev/null && pwd -P)" || ni "корня нет: $1"
VERDICT="$2"

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
[ -r "$SELF_DIR/lib_karta_sdachi.sh" ] || ni 'нет lib_karta_sdachi.sh рядом с дверью'
# ЕДИНЫЙ резолвер путей профиля (996) — подключается как библиотека, из СВОЕГО
# каталога: код барьера приходит не из проверяемого дерева.
[ -r "$SELF_DIR/next_id.sh" ] || ni 'нет next_id.sh рядом с дверью'
NEXT_ID_LIB=1
# shellcheck disable=SC1091
. "$SELF_DIR/next_id.sh"

# ── эффективный critic-каталог (И7) ───────────────────────────────────────────
# Отказ резолвера — именованный отказ БЕЗ fallback на корневую раскладку
# (битый профиль ≠ отсутствие профиля). Тот же приём, что в freeze_contract.sh.
_k193_paths=""
_k193_paths="$(project_paths_resolve "$ROOT" 2>&1)" \
  || otkaz "профиль битый или workflowPaths вне репо: $(printf '%s' "$_k193_paths" | tail -n 1)"
_k193_verdicts_abs="$(printf '%s' "$_k193_paths" | jq -r '.verdicts // empty' 2>/dev/null)"
unset _k193_paths
case "$_k193_verdicts_abs" in
    "$ROOT"/*) _k193_verdicts_rel="${_k193_verdicts_abs#"$ROOT"/}" ;;
    *)         otkaz "workflowPaths.verdicts вне корня: ${_k193_verdicts_abs:-<пусто>}" ;;
esac
unset _k193_verdicts_abs

case "$VERDICT" in
    "$_k193_verdicts_rel"/critic/*) : ;;
    *) otkaz "путь вердикта вне грамматики ${_k193_verdicts_rel}/critic/…: $VERDICT" ;;
esac
case "$VERDICT" in
    ''|/*|*..*) otkaz "путь вердикта вне грамматики (относительный, внутри корня): $VERDICT" ;;
esac

# shellcheck disable=SC1091
. "$SELF_DIR/lib_karta_sdachi.sh"

# ТОЛЬКО закоммиченный вердикт (AGENTS п.9): читаем HEAD-блоб
telo="$(git -C "$ROOT" cat-file -p "HEAD:$VERDICT" 2>/dev/null)"
[ -n "$telo" ] || otkaz "вердикт не закоммичен (AGENTS п.9): $VERDICT нет на HEAD"

grep -q '^## Карта классов$' <<<"$telo" \
    || otkaz "вердикт без раздела «## Карта классов»: $VERDICT"

spisok="$(karta_proverit "$telo")" || otkaz "$VERDICT: $spisok"
printf 'КАРТА: 17/17 зелёный\n'
exit 0
