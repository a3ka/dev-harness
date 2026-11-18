#!/usr/bin/env bash
# ДВЕРЬ КАРТЫ КЛАССОВ ВЕРДИКТА (контракт 193, Л2) — модель предмета
# (проектная ось 193↔996: профильный verdicts-каталог).
#
#   bash scripts/check_verdict_karta.sh <корень> <отн-путь-вердикта>
#
# Судит ТОЛЬКО ЗАКОММИЧЕННЫЙ вердикт (AGENTS.md п.8/9: истина — в закоммиченном
# исходнике; вердикт в переписке не переживает сессию): текст читается из
# HEAD-блоба, рабочее дерево не спрашивается. Грамматика секции «## Карта
# классов» — ЕДИНЫЙ ИСТОЧНИК scripts/lib_karta_sdachi.sh (И7); эта дверь
# грамматику не переизобретает.
#
# Грамматика ПУТИ (996 ↔ 193 И7): непустой относительный путь внутри
# critic-каталога ЭФФЕКТИВНОГО workflowPaths.verdicts из единого
# project_paths_resolve(ROOT) (next_id.sh рядом с дверью). Без профиля —
# штатный корневой результат резолвера `verdicts/critic/…`; при профильном
# каталоге корневой `verdicts/critic/…` НЕ запасной источник; отказ резолвера
# (битый профиль, workflowPaths вне репо) — именованный отказ, не fallback.
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
# единый резолвер путей профиля (996) — как библиотека, из СВОЕГО каталога
[ -r "$SELF_DIR/next_id.sh" ] || ni 'нет next_id.sh рядом с дверью'
NEXT_ID_LIB=1
# shellcheck disable=SC1091
. "$SELF_DIR/next_id.sh"

# эффективный verdicts-каталог: отказ резолвера — именованный отказ БЕЗ
# fallback на корневую раскладку (битый профиль ≠ отсутствие профиля)
_K193_PPR=""
_K193_PPR="$(project_paths_resolve "$ROOT" 2>&1)" \
  || otkaz "профиль битый или workflowPaths вне репо: $(printf '%s' "$_K193_PPR" | tail -n 1)"
_K193_VERDICTS_ABS="$(jq -r '.verdicts // empty' 2>/dev/null <<<"$_K193_PPR")"
case "$_K193_VERDICTS_ABS" in
    "$ROOT"/*) _K193_VERDICTS_REL="${_K193_VERDICTS_ABS#"$ROOT"/}" ;;
    *)         otkaz "workflowPaths.verdicts вне корня: ${_K193_VERDICTS_ABS:-<пусто>}" ;;
esac
unset _K193_PPR _K193_VERDICTS_ABS

case "$VERDICT" in
    "$_K193_VERDICTS_REL"/critic/*) : ;;
    *) otkaz "путь вердикта вне грамматики ${_K193_VERDICTS_REL}/critic/…: $VERDICT" ;;
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
